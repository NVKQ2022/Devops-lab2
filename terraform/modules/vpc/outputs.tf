output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [for k, s in aws_subnet.this : s.id if startswith(k, "public-")]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [for k, s in aws_subnet.this : s.id if startswith(k, "private-")]
}

output "public_subnet_cidrs" {
  description = "CIDRs of the public subnets"
  value = [for k, s in aws_subnet.this : s.cidr_block if startswith(k, "public-")]
}

output "private_subnet_cidrs" {
  description = "CIDRs of the private subnets"
  value = [for k, s in aws_subnet.this : s.cidr_block if startswith(k, "private-")]
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "azs" {
  description = "Availability zones used"
  value       = var.azs
}
