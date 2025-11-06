output "repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  description = "Nome do repositório"
  value       = aws_ecr_repository.main.name
}

output "repository_arn" {
  description = "ARN do repositório"
  value       = aws_ecr_repository.main.arn
}