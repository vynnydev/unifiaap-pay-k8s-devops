# UniFIAP Pay - Infraestrutura EKS na AWS
# Terraform Main Configuration

terraform {
  required_version = ">= 1.0"
  
  # Opcional: Backend S3 para state remoto
  # Descomente quando criar o bucket S3
  # backend "s3" {
  #   bucket = "unifiaap-terraform-state"
  #   key    = "eks/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Provider AWS
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "UniFIAP-Pay"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Compliance  = "BACEN"
      Owner       = "DevOps-Team"
    }
  }
}