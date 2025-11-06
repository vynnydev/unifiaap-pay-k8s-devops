variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
}

variable "azs" {
  description = "Lista de Availability Zones"
  type        = list(string)
}