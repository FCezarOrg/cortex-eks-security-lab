# ============================================================
# SECURITY LAB - EKS Pod Identity + IAM Attack Path
# ============================================================

resource "aws_iam_role" "demo_app_role" {
  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "pods.eks.amazonaws.com"
      }

      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })

  tags = {
    Name        = "${var.project_name}-app-role"
    Project     = var.project_name
    Environment = "security-lab"
    Purpose     = "EKS-Pod-Identity-Demo"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Intentionally privileged target role
# ============================================================

resource "aws_iam_role" "demo_privileged_role" {
  name = "${var.project_name}-privileged-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-privileged-role"
    Project     = var.project_name
    Environment = "security-lab"
    Purpose     = "IAM-Attack-Path-Demo"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "demo_privileged_policy" {
  name = "SecurityLabPrivilegedPolicy"
  role = aws_iam_role.demo_privileged_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "DemoS3PrivilegedAccess"
      Effect = "Allow"

      Action = [
        "s3:*"
      ]

      Resource = [
        aws_s3_bucket.demo_sensitive_data.arn,
        "${aws_s3_bucket.demo_sensitive_data.arn}/*"
      ]
    }]
  })
}

# ============================================================
# Application workload permissions
# ============================================================

resource "aws_iam_role_policy" "demo_app_policy" {
  name = "SecurityLabAppPolicy"
  role = aws_iam_role.demo_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListSensitiveDemoBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.demo_sensitive_data.arn
      },
      {
        Sid    = "SensitiveDemoObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.demo_sensitive_data.arn}/*"
      },

      # --------------------------------------------------------
      # INTENTIONAL SECURITY LAB RISK
      #
      # The application workload can pass a more privileged
      # role to AWS Lambda.
      # --------------------------------------------------------

      {
        Sid    = "PassPrivilegedDemoRole"
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = aws_iam_role.demo_privileged_role.arn

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },
      {
        Sid    = "ManageDemoLambda"
        Effect = "Allow"

        Action = [
          "lambda:CreateFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration"
        ]

        Resource = "arn:${data.aws_partition.current.partition}:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.project_name}-*"
      }
    ]
  })
}

# ============================================================
# EKS Pod Identity
# ============================================================

resource "aws_eks_pod_identity_association" "demo_app" {
  cluster_name    = module.eks.cluster_name
  namespace       = var.kubernetes_namespace
  service_account = var.app_service_account
  role_arn        = aws_iam_role.demo_app_role.arn

  tags = {
    Project     = var.project_name
    Environment = "security-lab"
    ManagedBy   = "Terraform"
  }
}
