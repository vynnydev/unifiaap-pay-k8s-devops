variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
}

# variable "node_instance_type" {
#   description = "Tipo de instância dos nodes"
#   type        = string
# }

# variable "node_desired_size" {
#   description = "Número desejado de nodes"
#   type        = number
# }

# variable "node_min_size" {
#   description = "Número mínimo de nodes"
#   type        = number
# }

# variable "node_max_size" {
#   description = "Número máximo de nodes"
#   type        = number
# }