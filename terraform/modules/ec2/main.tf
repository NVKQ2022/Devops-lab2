resource "aws_instance" "this" {
  for_each = var.instances

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.vpc_security_group_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}
