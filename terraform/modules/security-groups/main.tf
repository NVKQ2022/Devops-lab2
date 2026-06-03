resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = [for r in each.value.ingress_rules : r if try(r.source_sg_key, null) == null]
    content {
      description     = try(ingress.value.description, null)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = try(ingress.value.cidr_blocks, null)
      security_groups = try(ingress.value.source_sg_ids, null)
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      description = try(egress.value.description, null)
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = try(egress.value.cidr_blocks, null)
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}

resource "aws_security_group_rule" "ingress_cross" {
  for_each = {
    for pair in flatten([
      for sg_key, sg in var.security_groups : [
        for idx, rule in sg.ingress_rules : {
          key    = "${sg_key}-${idx}"
          sg_key = sg_key
          rule   = rule
        } if try(rule.source_sg_key, null) != null
      ]
    ]) : pair.key => pair
  }

  description              = try(each.value.rule.description, null)
  type                     = "ingress"
  from_port                = each.value.rule.from_port
  to_port                  = each.value.rule.to_port
  protocol                 = each.value.rule.protocol
  source_security_group_id = aws_security_group.this[each.value.rule.source_sg_key].id
  security_group_id        = aws_security_group.this[each.value.sg_key].id
}


