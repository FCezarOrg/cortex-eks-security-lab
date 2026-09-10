output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "github_deploy_role_arn" {
  description = "IAM role ARN used by GitHub Actions to deploy the application"
  value       = aws_iam_role.github_actions.arn
}

output "sensitive_s3_bucket_name" {
  description = "Name of the synthetic sensitive-data S3 bucket"
  value       = aws_s3_bucket.demo_sensitive_data.bucket
}
