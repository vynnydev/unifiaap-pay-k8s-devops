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

variable "db_name" {
  description = "Nome do banco"
  type        = string
}

variable "db_username" {
  description = "Username do banco"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password do banco"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Classe da instância"
  type        = string
}