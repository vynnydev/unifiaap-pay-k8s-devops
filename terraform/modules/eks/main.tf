# UniFIAP Pay - Módulo EKS
# Cria Cluster EKS e Node Groups

locals {
  name = "${var.project_name}-${var.environment}-eks"
}

# IAM Role para EKS Cluster
resource "aws_iam_role" "cluster" {
  name = "${local.name}-cluster-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Security Group para EKS Cluster
resource "aws_security_group" "cluster" {
  name        = "${local.name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${local.name}-cluster-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = local.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version
  
  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
  
  tags = {
    Name = local.name
  }
}

# IAM Role para Node Group
resource "aws_iam_role" "node" {
  name = "${local.name}-node-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  
  policy_arn = each.value
  role       = aws_iam_role.node.name
}

# EKS Node Group
# EKS Node Group com SPOT
# resource "aws_eks_node_group" "main" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "${local.name}-node-group"
#   node_role_arn   = aws_iam_role.node.arn
#   subnet_ids      = var.private_subnet_ids
  
#   capacity_type = "SPOT"
  
#   instance_types = [
#     "t3.medium",
#     "t3a.medium",
#     "t2.medium"
#   ]
  
#   scaling_config {
#     desired_size = var.node_desired_size
#     max_size     = var.node_max_size
#     min_size     = var.node_min_size
#   }
  
#   update_config {
#     max_unavailable = 1
#   }
  
#   depends_on = [
#     aws_iam_role_policy_attachment.node_policy
#   ]
  
#   tags = {
#     Name = "${local.name}-node-group"
#   }
# }

# OIDC Provider para o cluster
# data "tls_certificate" "cluster" {
#   url = aws_eks_cluster.main.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "cluster" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  
#   tags = {
#     Name = "${local.name}-oidc-provider"
#   }
# }

# EBS CSI Driver IAM Role
# resource "aws_iam_role" "ebs_csi" {
#   name = "${local.name}-ebs-csi-role"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.cluster.arn
#       }
#       Condition = {
#         StringEquals = {
#           "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#           "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:aud": "sts.amazonaws.com"
#         }
#       }
#     }]
#   })
  
#   depends_on = [
#     aws_iam_openid_connect_provider.cluster
#   ]
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi.name
# }

# EKS Addon - EBS CSI Driver
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name             = aws_eks_cluster.main.name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.25.0-eksbuild.1"
#   service_account_role_arn = aws_iam_role.ebs_csi.arn
  
#   depends_on = [
#     aws_eks_node_group.main
#   ]
# }