variable "aws_region" {
  description = "AWS region used by the security lab"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Base name used by the security lab resources"
  type        = string
  default     = "cortex-eks-security-lab"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cortex-security-lab"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace used by the demo application"
  type        = string
  default     = "cortex-security-lab"
}

variable "app_service_account" {
  description = "Kubernetes service account used by the demo application"
  type        = string
  default     = "cortex-security-lab-app"
}

variable "github_org" {
  description = "GitHub organization or username owning the repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_org_id" {
  description = "Immutable GitHub organization/user ID"
  type        = string
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID"
  type        = string
}

variable "eks_admin_principal_arn" {
  description = "Optional IAM principal that receives EKS cluster administrator access"
  type        = string
  default     = ""
}

variable "terraform_role_arn" {
  description = "ARN of the GitHub Terraform role created by bootstrap"
  type        = string
}
