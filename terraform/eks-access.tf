# ============================================================
# GitHub Application Deploy Role - EKS Access
# ============================================================

resource "aws_eks_access_entry" "github" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  tags = {
    Project              = var.project_name
    Environment          = "security-lab"
    ManagedBy            = "Terraform"
    git_commit           = "286a11d4c4f88fa2f82712bea09f85ee29ce7c13"
    git_file             = "terraform/eks-access.tf"
    git_last_modified_at = "2026-09-10 16:57:43"
    git_modifiers        = "fa_cezar"
    git_org              = "FCezarOrg"
    git_repo             = "cortex-eks-security-lab"
    yor_name             = "github"
    yor_trace            = "13e69487-c63b-4186-97d4-9148bf20c5f1"
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

# ============================================================
# GitHub Application Deploy Role - Cluster Administration
#
# Required because the application pipeline installs the
# AWS Load Balancer Controller, which creates cluster-scoped
# Kubernetes resources.
# ============================================================

resource "aws_eks_access_policy_association" "github_cluster_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
