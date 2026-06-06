locals {
  cluster_name = "${var.name_prefix}-eks-cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access

  authentication_mode = var.authentication_mode

  enable_cluster_creator_admin_permissions = true
  access_entries = var.access_entries

  create_auto_mode_iam_resources = true
  compute_config = {
    enabled = true
  }

  tags = var.tags
}
