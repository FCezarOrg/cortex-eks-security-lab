# ============================================================
# GitHub Application Deploy Role - EKS Access
# ============================================================

resource "aws_eks_access_entry" "github" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  tags = {
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_eks_access_policy_association" "github" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [var.kubernetes_namespace]
  }
}
