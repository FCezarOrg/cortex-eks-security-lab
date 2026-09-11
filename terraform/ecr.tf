resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name                 = "${var.project_name}-app"
    Project              = var.project_name
    Environment          = "security-lab"
    ManagedBy            = "Terraform"
    git_commit           = "286a11d4c4f88fa2f82712bea09f85ee29ce7c13"
    git_file             = "terraform/ecr.tf"
    git_last_modified_at = "2026-09-10 16:57:43"
    git_modifiers        = "fa_cezar"
    git_org              = "FCezarOrg"
    git_repo             = "cortex-eks-security-lab"
    yor_name             = "app"
    yor_trace            = "35a5d640-3ae3-4c10-b292-66b23a25f685"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
