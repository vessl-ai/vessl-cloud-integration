data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  node_group_name        = "${var.cluster_name}-node-group"
  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

# -----------
# EKS cluster
# -----------
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  create_iam_role = var.cluster_iam_role_arn == null ? true : false
  iam_role_arn    = var.cluster_iam_role_arn == null ? null : var.cluster_iam_role_arn

  # Essential add-ons
  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Enable IAM Roles for Service Account(IRSA)
  # See also: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  enable_irsa = true

  # Enable aws-auth configmap (configmap for managing cluster access for IAM roles and users)
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_node_iam_role_arns_non_windows = [aws_iam_role.node_group.arn]

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

  # Use external cluster encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  # Enable discovery of autoscaling groups by cluster-autoscaler
  self_managed_node_group_defaults = {
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.cluster_name}" : "owned",
    }
    iam_role_attach_cni_policy = true
  }

  tags = var.tags
}

# ----------------------
# Cluster encryption key
# ----------------------
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  aliases               = ["eks/${var.cluster_name}"]
  description           = "[${var.cluster_name}] EKS cluster encryption key"
  enable_default_policy = true

  key_owners = concat(
    [
      for user in var.cluster_master_iam_users :
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
    ],
    [for _, role in var.cluster_master_iam_roles : role],
  )

  tags = var.tags
}

# --------------------
# Node group IAM Roles
# --------------------
resource "aws_iam_role" "node_group" {
  name        = local.node_group_name
  path        = "/"
  description = "[${var.cluster_name}] IAM role for EKS cluster node group"

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "node_group" {
  for_each = { for k, v in toset(compact([
    "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy",
  ])) : k => v }

  policy_arn = each.value
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_instance_profile" "node_group" {
  role = aws_iam_role.node_group.name
  name = local.node_group_name
  path = "/"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
