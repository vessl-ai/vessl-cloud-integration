locals {
  private_subnet_ids = values(var.private_subnets)
  public_subnet_ids  = values(var.public_subnets)
}

# ---------------------------
# EKS cluster (control plane)
# ---------------------------
module "eks" {
  source = "github.com/vessl-ai/vessl-cloud-integration/modules/eks-cluster"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = concat(local.private_subnet_ids, local.public_subnet_ids)

  cluster_master_iam_users = var.cluster_master_iam_users
  cluster_master_iam_roles = var.cluster_master_iam_roles

  tags = var.tags
}

# -------------------------------------------------------------
# EKS self-managed node groups (one per each availability zone)
# -------------------------------------------------------------
data "aws_subnet" "public_subnets" {
  for_each = toset(local.public_subnet_ids)
  id       = each.key
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
  # Group subnets by availability zone
  availability_zone_subnets = {
    for s in data.aws_subnet.public_subnets : s.availability_zone => s.id...
  }
}

module "eks_self_managed_node_group" {
  for_each = local.availability_zone_subnets

  source = "github.com/vessl-ai/vessl-cloud-integration/modules/eks-self-managed-node-group"

  instance_type = "t3.large"
  min_size      = 0
  max_size      = 10

  cluster_name                       = module.eks.cluster_name
  cluster_version                    = module.eks.cluster_version
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
  ]
  availability_zone        = each.key
  subnet_ids               = each.value
  iam_instance_profile_arn = module.eks.cluster_node_iam_instance_profile_arn

  node_template_labels = {
    "app.vessl.ai/v1.cpu-1.mem-4" : "true",
    "app.vessl.ai/v1.cpu-2.mem-8" : "true",
  }
  node_template_resources = {
    "ephemeral-storage" : "100Gi"
  }
  tags = var.tags
}

# ----------------------------------------------------
# Kubernetes addons
# e.g. alb controller, autoscaler, cluster agent, etc.
# ----------------------------------------------------
module "addons_aws_load_balancer_controller" {
  source           = "github.com/vessl-ai/vessl-cloud-integration/modules/kubernetes-addons/aws-load-balancer-controller"
  eks_cluster_name = module.eks.cluster_name
  oidc_issuer_url  = module.eks.oidc_issuer_url
}

module "addons_aws_cluster_autoscaler" {
  source              = "github.com/vessl-ai/vessl-cloud-integration/modules/kubernetes-addons/aws-cluster-autoscaler"
  eks_cluster_name    = module.eks.cluster_name
  eks_cluster_version = var.cluster_version
  oidc_issuer_url     = module.eks.oidc_issuer_url
}

module "addons_aws_ebs_csi_driver" {
  source           = "github.com/vessl-ai/vessl-cloud-integration/modules/kubernetes-addons/aws-ebs-csi-driver"
  eks_cluster_name = module.eks.cluster_name
  oidc_issuer_url  = module.eks.oidc_issuer_url
}

module "addons_nvidia_gpu_operator" {
  source           = "github.com/vessl-ai/vessl-cloud-integration/modules/kubernetes-addons/nvidia-gpu-operator"
  eks_cluster_name = module.eks.cluster_name
}

module "addons_vessl_cluster_agent" {
  source           = "github.com/vessl-ai/vessl-cloud-integration/modules/kubernetes-addons/vessl-cluster-agent"
  eks_cluster_name = module.eks.cluster_name
  k8s_namespace    = var.cluster_agent_namespace

  vessl_cluster_agent_option = {
    provider_type            = "aws"
    vessl_agent_access_token = var.vessl_agent_access_token
    local_storage_class_name = var.local_storage_class_name
    environment              = "prod",
    ingress_endpoint         = "",
    log_level                = "info",
    vessl_api_server         = "https://api.vessl.ai"
  }

  helm_values = {
    "metricsExporters.dcgmExporter.enabled" = "false"
    "nvidia-device-plugin.enabled"          = "false"
    "nvidia-device-plugin.nfd.enabled"      = "false"
    "nvidia-device-plugin.gfd.enabled"      = "false"
    "localPathProvisioner.enabled"          = "false"
  }
}
