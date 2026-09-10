# ============================================================
# Existing GitHub Actions OIDC Provider
# ============================================================
#
# The GitHub OIDC provider already exists in this AWS account,
# therefore Terraform references it instead of creating another.
#

data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# ============================================================
# GitHub Actions Deploy Role
# ============================================================

resource "aws_iam_role" "github_actions" {
  name        = "${var.project_name}-deploy-role"
  description = "Role assumed by GitHub Actions through OIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "GitHubActionsOIDC"
        Effect = "Allow"

        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github_actions.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"

            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}@${var.github_org_id}/${var.github_repo}@${var.github_repo_id}:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-deploy-role"
    ManagedBy = "Terraform"
    Purpose   = "GitHubActionsEKSDeploy"
    yor_trace = "747077c8-3e08-4acb-87e2-91a9a09ffb36"
    yor_name  = "github_actions"
  }
}

# ============================================================
# ECR permissions
# ============================================================

resource "aws_iam_role_policy" "github_ecr" {
  name = "GitHubECRAccess"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ECRAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryAccess"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]

        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}

# ============================================================
# EKS permissions
# ============================================================

resource "aws_iam_role_policy" "github_eks" {
  name = "GitHubEKSAccess"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EKSClusterAccess"
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = module.eks.cluster_arn
      }
    ]
  })
}
