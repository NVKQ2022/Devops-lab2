locals {
  subnet_defs = merge({
    for i, c in var.public_subnet_cidrs :
    "public-${i + 1}" => {
      cidr_block = c
      az         = var.azs[i % length(var.azs)]
      public     = true
      extra_tags = var.subnet_tags["public"]
    }
  }, {
    for i, c in var.private_subnet_cidrs :
    "private-${i + 1}" => {
      cidr_block = c
      az         = var.azs[i % length(var.azs)]
      public     = false
      extra_tags = var.subnet_tags["private"]
    }
  })

  private_subnet_keys = sort([for k, v in local.subnet_defs : k if !v.public])
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_subnet" "this" {
  for_each = local.subnet_defs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = merge(var.tags, each.value.extra_tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway && var.single_nat_gateway ? 1 : var.enable_nat_gateway ? length(var.azs) : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : var.enable_nat_gateway ? length(var.azs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.this["public-${count.index + 1}"].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in local.subnet_defs : k => v if v.public
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = var.enable_nat_gateway ? length(local.private_subnet_keys) : 0

  subnet_id      = aws_subnet.this[local.private_subnet_keys[count.index]].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index % length(var.azs)].id
}
