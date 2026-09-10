# ============================================================
# Availability Zones
# ============================================================

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {}


# ============================================================
# VPC
# ============================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name = "${var.cluster_name}-vpc"
  cidr = "10.20.0.0/16"

  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    3
  )

  private_subnets = [
    "10.20.1.0/24",
    "10.20.2.0/24",
    "10.20.3.0/24"
  ]

  public_subnets = [
    "10.20.101.0/24",
    "10.20.102.0/24",
    "10.20.103.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  tags = {
  }
}


# ============================================================
# EKS
# ============================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.24"

  name               = var.cluster_name
  kubernetes_version = "1.34"

  endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Explicit EKS administration is managed separately.
  # This avoids changing cluster admin depending on
  # which identity executes Terraform.
  enable_cluster_creator_admin_permissions = false

  # ==========================================================
  # KMS Administrators
  #
  # Explicitly defined so the KMS key policy does not change
  # depending on whether Terraform runs locally or in GitHub.
  # ==========================================================

  kms_key_administrators = [
    var.terraform_role_arn,
    var.eks_admin_principal_arn
  ]

  # ==========================================================
  # EKS Add-ons
  # ==========================================================

  addons = {
    coredns = {}

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }

    eks-pod-identity-agent = {
      before_compute = true
    }

    aws-ebs-csi-driver = {}
  }

  # ==========================================================
  # Managed Node Group
  # ==========================================================

  eks_managed_node_groups = {
    demo = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      ami_type = "AL2023_x86_64_STANDARD"

      # ======================================================
      # SECURITY LAB ONLY
      #
      # IMDSv1 intentionally permitted.
      #
      # http_tokens = "optional" allows IMDSv1 + IMDSv2.
      # Hop limit 2 also permits metadata access from pods
      # in common container networking scenarios.
      #
      # Do not use this configuration in production.
      # ======================================================

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
  }
  tags = {
  }
}
