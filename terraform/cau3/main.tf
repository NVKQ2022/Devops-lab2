data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-cau3"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "../modules/vpc"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  azs         = local.azs

  public_subnet_cidrs  = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i + length(local.azs))]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "eks" {
  source = "../modules/eks"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id

  subnet_ids          = module.vpc.private_subnet_ids
  node_subnet_ids     = module.vpc.private_subnet_ids
  cluster_version     = var.cluster_version
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
