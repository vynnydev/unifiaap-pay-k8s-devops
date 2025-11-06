# UniFIAP Pay - Terraform Outputs

output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_configure_kubectl" {
  description = "Comando kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "ecr_repository_url" {
  description = "URL do ECR"
  value       = module.ecr.repository_url
}

output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "next_steps" {
  description = "Próximos passos"
  value       = <<-EOT
    
    1. Configure kubectl:
       ${module.eks.configure_kubectl_command}
    
    2. Login no ECR:
       aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.ecr.repository_url}
    
    3. Deploy:
       cd ../k8s && ./deploy.sh
  EOT
}