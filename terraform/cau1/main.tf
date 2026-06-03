data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
  ami_id      = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux.id
}

module "vpc" {
  source = "../modules/vpc"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  azs         = local.azs

  public_subnet_cidrs  = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i + length(local.azs))]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "security_groups" {
  source = "../modules/security-groups"

  name_prefix = local.name_prefix

  security_groups = {
    instance = {
      description = "Security group for EC2 instance"
      vpc_id      = module.vpc.vpc_id
      ingress_rules = [
        {
          description = "SSH from allowed CIDRs"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = var.allowed_ssh_cidrs
        }
      ]
      egress_rules = [
        {
          description = "All outbound traffic"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "ec2" {
  source = "../modules/ec2"

  name_prefix = local.name_prefix

  instances = {
    instance = {
      ami                         = local.ami_id
      instance_type               = var.instance_type
      subnet_id                   = module.vpc.public_subnet_ids[0]
      vpc_security_group_ids      = [module.security_groups.sg_ids["instance"]]
      associate_public_ip_address = true
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [
    module.vpc,
    module.security_groups
  ]
}
