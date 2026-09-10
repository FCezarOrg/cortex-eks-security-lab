variable "aws_region" {
  description = "AWS region used by the security lab"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Base project name"
  type        = string
  default     = "cortex-eks-security-lab"
}

variable "github_org" {
  description = "GitHub organization or username"
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

variable "github_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN. Leave empty to create a new provider."
  type        = string
  default     = ""
}
