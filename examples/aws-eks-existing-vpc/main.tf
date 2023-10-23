data "aws_ami" "eks_cpu" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

data "aws_ami" "eks_gpu" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

locals {
  private_subnet_ids = values(var.private_subnets)
  public_subnet_ids  = values(var.public_subnets)
}

# ---------------------------
# IAM resources for EKS cluster nodes
# ---------------------------
module "eks_node_group_iam" {
  source  = "vessl-ai/vessl-eks-node-group-iam/aws"
  version = "0.0.2"

  cluster_name = var.cluster_name
  tags         = var.tags
}

# ---------------------------
# EKS cluster (control plane)
# ---------------------------
module "eks" {
  source                   = "terraform-aws-modules/eks/aws"
  version                  = "19.17.2"
  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  control_plane_subnet_ids = local.private_subnet_ids
  subnet_ids               = local.private_subnet_ids
  vpc_id                   = var.vpc_id
  enable_irsa              = true

  cluster_endpoint_public_access = true

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  # IAM users to hold system:masters access
  aws_auth_users = [
    for user in var.cluster_master_iam_users : {
      userarn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
      username = user
      groups   = ["system:masters"]
    }
  ]

  # IAM roles to hold system:masters access
  aws_auth_roles = [
    for username, role in var.cluster_master_iam_roles : {
      rolearn  = replace(role, "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.name}", "")
      username = username
      groups   = ["system:masters"]
    }
  ]

  aws_auth_node_iam_role_arns_non_windows = [module.eks_node_group_iam.iam_role_arn]

  tags = var.tags
}

# --------------------------------------
# EKS self-managed node groups (workers)
# --------------------------------------
module "eks_node_groups" {
  source  = "vessl-ai/vessl-eks-node-groups/aws"
  version = "0.0.7"

  cluster_name                       = module.eks.cluster_name
  cluster_version                    = module.eks.cluster_version
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  vpc_id = var.vpc_id
  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
  ]

  manager_node_count         = 1
  manager_node_ami_id        = data.aws_ami.eks_cpu.id
  manager_node_instance_type = "m6i.large"
  manager_node_disk_size     = 100
  manager_node_subnet_ids    = local.public_subnet_ids

  iam_instance_profile_arn = module.eks_node_group_iam.iam_instance_profile_arn

  self_managed_node_groups_data = {
    "t4-1" : {
      min_size          = 0
      max_size          = 1
      desired_size      = 1
      instance_type     = "g4dn.xlarge"
      name              = "t4-1"
      subnet_ids        = [local.private_subnet_ids[0]]
      disk_size         = 500
      availability_zone = "us-east-1a"
      ami_id            = data.aws_ami.eks_gpu.id
      node_template_resources = {
        ephemeral-storage = "500Gi"
      }
    }
  }

  tags = var.tags
}

module "eks_addons" {
  depends_on = [module.eks_node_groups]

  source  = "vessl-ai/vessl-eks-addons/aws"
  version = "0.0.16"

  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  coredns = {
    version = "v1.9.3-eksbuild.5"
  }
  vpc_cni = {
    version = "v1.13.2-eksbuild.1"
  }
  kube_proxy = {
    version = "v1.25.11-eksbuild.1"
  }
  ebs_csi_driver = {
    version            = "v1.19.0-eksbuild.2"
    storage_class_name = "vessl-ebs"
  }

  #  external_dns = {
  #    cluster_domain = local.full_domain
  #    namespace      = "kube-system"
  #    version        = "1.13.0"
  #    sources        = ["service"]
  #  }
  #  ingress_nginx = {
  #    namespace = "kube-system"
  #    version   = "4.7.0"
  #    service_annotations = {
  #      "external-dns.alpha.kubernetes.io/hostname"                            = "*.${local.full_domain}"
  #      "service.beta.kubernetes.io/aws-load-balancer-type"                    = "external"
  #      "service.beta.kubernetes.io/aws-load-balancer-scheme"                  = "internet-facing"
  #      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"         = "ip"
  #      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "tcp"
  #      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "https"
  #      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "60"
  #      "service.beta.kubernetes.io/aws-load-balancer-subnets"                 = join(",", local.public_subnet_ids)
  #      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = aws_acm_certificate.ingress.arn
  #      "service.beta.kubernetes.io/aws-load-balancer-attributes"              = "load_balancing.cross_zone.enabled=true"
  #    }
  #    ssl_termination = true
  #  }
  load_balancer_controller = {
    namespace = "kube-system"
    version   = "1.4.5"
  }
  cluster_autoscaler = {
    namespace = "kube-system"
    version   = "9.24.0"
  }
  metrics_server = {
    version = "3.10.0"
  }

  tags = var.tags
}
