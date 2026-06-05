locals {
  cluster_name = "${var.name_prefix}-eks-cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.node_subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access

  enable_cluster_creator_admin_permissions = true
  authentication_mode = var.authentication_mode

  eks_managed_node_groups = {
    default = {
      subnet_ids   = var.node_subnet_ids
      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
    }
  }

  tags = var.tags
}
