# UniFIAP Pay - Terraform Variables

variable "aws_region" {
  description = "Região AWS para deploy"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "unifiaap-pay"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.28"
}

# variable "eks_node_instance_type" {
#   description = "Tipo de instância EC2"
#   type        = string
#   default     = "t3.medium"
# }

# variable "eks_node_desired_size" {
#   description = "Número desejado de nodes"
#   type        = number
#   default     = 1
# }

# variable "eks_node_min_size" {
#   description = "Número mínimo de nodes"
#   type        = number
#   default     = 1
# }

# variable "eks_node_max_size" {
#   description = "Número máximo de nodes"
#   type        = number
#   default     = 2
# }

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "pixdb"
}

variable "db_username" {
  description = "Username do banco"
  type        = string
  default     = "pixuser"
  sensitive   = true
}

variable "db_password" {
  description = "Password do banco"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}