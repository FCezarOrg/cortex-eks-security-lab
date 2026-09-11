# ============================================================
# Explicit EKS administrator access
# ============================================================

resource "aws_eks_access_entry" "lab_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.eks_admin_principal_arn
  type          = "STANDARD"

  tags = {
    Project              = var.project_name
    Environment          = "security-lab"
    ManagedBy            = "Terraform"
    git_commit           = "286a11d4c4f88fa2f82712bea09f85ee29ce7c13"
    git_file             = "terraform/eks-admin-access.tf"
    git_last_modified_at = "2026-09-10 16:57:43"
    git_modifiers        = "fa_cezar"
    git_org              = "FCezarOrg"
    git_repo             = "cortex-eks-security-lab"
    yor_name             = "lab_admin"
    yor_trace            = "d5f25293-a890-46d9-8b4c-6f87ea9c96ca"
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
