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
    Name      = "${var.project_name}-aws-lbc"
    ManagedBy = "Terraform"
    Purpose   = "AWSLoadBalancerController"
  }
}
