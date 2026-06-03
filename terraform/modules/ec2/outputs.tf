output "instance_ids" {
  description = "Map of instance IDs keyed by name"
  value = {
    for k, inst in aws_instance.this : k => inst.id
  }
}

output "instance_public_ips" {
  description = "Map of public IPs keyed by name"
  value = {
    for k, inst in aws_instance.this : k => inst.public_ip
  }
}

output "instance_private_ips" {
  description = "Map of private IPs keyed by name"
  value = {
    for k, inst in aws_instance.this : k => inst.private_ip
  }
}

output "instance_public_dns" {
  description = "Map of public DNS names keyed by name"
  value = {
    for k, inst in aws_instance.this : k => inst.public_dns
  }
}
