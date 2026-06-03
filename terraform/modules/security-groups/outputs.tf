output "sg_ids" {
  description = "Map of security group IDs keyed by their configured key"
  value = {
    for k, sg in aws_security_group.this : k => sg.id
  }
}

output "sg_arns" {
  description = "Map of security group ARNs keyed by their configured key"
  value = {
    for k, sg in aws_security_group.this : k => sg.arn
  }
}
