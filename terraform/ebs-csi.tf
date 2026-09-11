# ============================================================
# Amazon EBS CSI Driver - Pod Identity
# ============================================================

resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Project              = var.project_name
    Environment          = "security-lab"
    Purpose              = "EBS-CSI-Pod-Identity"
    ManagedBy            = "Terraform"
    git_commit           = "286a11d4c4f88fa2f82712bea09f85ee29ce7c13"
    git_file             = "terraform/ebs-csi.tf"
    git_last_modified_at = "2026-09-10 16:57:43"
    git_modifiers        = "fa_cezar"
    git_org              = "FCezarOrg"
    git_repo             = "cortex-eks-security-lab"
    yor_name             = "ebs_csi"
    yor_trace            = "eddea88a-7d6b-472e-9236-b38bcb988e37"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn

  tags = {
    Project              = var.project_name
    Environment          = "security-lab"
    ManagedBy            = "Terraform"
    git_commit           = "286a11d4c4f88fa2f82712bea09f85ee29ce7c13"
    git_file             = "terraform/ebs-csi.tf"
    git_last_modified_at = "2026-09-10 16:57:43"
    git_modifiers        = "fa_cezar"
    git_org              = "FCezarOrg"
    git_repo             = "cortex-eks-security-lab"
    yor_name             = "ebs_csi"
    yor_trace            = "d6f547e5-61cf-4aa0-aba2-1dba3ab58796"
  }
}
