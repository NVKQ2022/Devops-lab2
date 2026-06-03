output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "The API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "The certificate authority data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "The security group ID attached to the cluster"
  value       = aws_security_group.cluster.id
}

output "node_group_id" {
  description = "The ID of the node group"
  value       = aws_eks_node_group.this.id
}

output "node_group_arn" {
  description = "The ARN of the node group"
  value       = aws_eks_node_group.this.arn
}
