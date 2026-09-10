terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "security-lab"
      ManagedBy   = "Terraform-Bootstrap"
    }
  }
}

data "aws_caller_identity" "current" {}

# ============================================================
# GitHub Actions OIDC Provider
#
# If an OIDC provider ARN is supplied, reuse it.
# Otherwise, create a provider in the current AWS account.
# ============================================================

resource "aws_iam_openid_connect_provider" "github" {
  count = var.github_oidc_provider_arn == "" ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

locals {
  github_oidc_provider_arn = (
    var.github_oidc_provider_arn != ""
    ? var.github_oidc_provider_arn
    : aws_iam_openid_connect_provider.github[0].arn
  )
}

# ============================================================
# Terraform remote-state bucket
# ============================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "${var.project_name}-tfstate"
    Purpose = "TerraformRemoteState"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ============================================================
# GitHub Terraform Role
# ============================================================

resource "aws_iam_role" "github_terraform" {
  name        = "${var.project_name}-terraform-role"
  description = "GitHub Actions role used to deploy the security lab"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "GitHubActionsOIDC"
      Effect = "Allow"

      Principal = {
        Federated = local.github_oidc_provider_arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}@${var.github_org_id}/${var.github_repo}@${var.github_repo_id}:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    Name    = "${var.project_name}-terraform-role"
    Purpose = "GitHubTerraformInfrastructure"
  }
}

# SECURITY LAB:
# Intentionally broad infrastructure permissions.
# Do not reuse this policy for production environments.

resource "aws_iam_role_policy" "github_terraform" {
  name = "SecurityLabTerraformInfrastructure"
  role = aws_iam_role.github_terraform.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "LabInfrastructure"
        Effect = "Allow"

        Action = [
          "ec2:*",
          "eks:*",
          "ecr:*",
          "iam:*",
          "kms:*",
          "logs:*",
          "s3:*"
        ]

        Resource = "*"
      },
      {
        Sid    = "SSMRead"
        Effect = "Allow"

        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]

        Resource = "*"
      },
      {
        Sid      = "STSIdentity"
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "terraform_state_bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "terraform_role_arn" {
  value = aws_iam_role.github_terraform.arn
}

output "github_oidc_provider_arn" {
  value = local.github_oidc_provider_arn
}
