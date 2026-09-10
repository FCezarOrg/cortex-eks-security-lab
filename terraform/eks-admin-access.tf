# ============================================================
# Explicit EKS administrator access
# ============================================================

resource "aws_eks_access_entry" "lab_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.eks_admin_principal_arn
  type          = "STANDARD"

  tags = {
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_eks_access_policy_association" "lab_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.lab_admin.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
