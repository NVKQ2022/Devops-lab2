data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

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

  subnet_tags = {
    public = {
      "kubernetes.io/role/elb" = "1"
    }
    private = {
      "kubernetes.io/role/internal-elb" = "1"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "eks" {
  source = "../modules/eks"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id

  subnet_ids              = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  cluster_version         = var.cluster_version
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access

  access_entries = {
    root = {
      principal_arn = "arn:aws:iam::${var.admin_account_id}:root"
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



