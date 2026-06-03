output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_ids["instance"]
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.instance_public_ips["instance"]
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2.instance_private_ips["instance"]
}

output "instance_security_group_id" {
  description = "The ID of the security group"
  value       = module.security_groups.sg_ids["instance"]
}
