# UniFIAP Pay - Fargate Profile

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${local.name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnet_ids
  
  selector {
    namespace = "unifiappay"
  }
  
  selector {
    namespace = "kube-system"
  }
  
  tags = {
    Name = "${local.name}-fargate-profile"
  }
}

resource "aws_iam_role" "fargate" {
  name = "${local.name}-fargate-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  
  tags = {
    Name = "${local.name}-fargate-role"
  }
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}