# ============================================================
# AWS Load Balancer Controller - EKS Pod Identity
# ============================================================

module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.9.0"

  name = "${var.project_name}-aws-lbc"

  attach_aws_lb_controller_policy = true

  associations = {
    this = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = {
    Name                 = "${var.project_name}-aws-lbc"
    ManagedBy            = "Terraform"
    Purpose              = "AWSLoadBalancerController"
    git_commit           = "5bacc0bdf2acb2cf157749ee4f396452680e1a7e"
    git_file             = "terraform/alb-controller.tf"
    git_last_modified_at = "2026-09-11 04:42:36"
    git_modifiers        = "fa_cezar"
    git_org              = "FCezarOrg"
    git_repo             = "cortex-eks-security-lab"
    yor_name             = "aws_lb_controller_pod_identity"
    yor_trace            = "a8846ca1-93b7-4964-8f23-a2df54745569"
  }
}
