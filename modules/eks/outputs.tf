output "cluster_endpoint" {
  value = aws_eks_cluster.eks_main_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.eks_main_cluster.name
}