output "cluster_id" {
  description = "ID do cluster EKS"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "Nome do cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Versão do Kubernetes"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group do cluster"
  value       = aws_security_group.cluster.id
}

output "configure_kubectl_command" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${aws_eks_cluster.main.arn}"
}