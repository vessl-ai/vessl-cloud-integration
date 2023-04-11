data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = var.oidc_issuer_url
}

# --------------------------------------------------------------------
# IAM Role to use for the cluster-autoscaler service account
# --------------------------------------------------------------------
resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.eks_cluster_name}-${var.helm_release_name}-irsa"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_irsa.json
  description        = "AWS IAM Role for the Kubernetes service account ${var.k8s_namespace}:${var.k8s_service_account_name}"

  force_detach_policies = true
  tags                  = var.tags
}

# Assume role policy for IRSA
data "aws_iam_policy_document" "cluster_autoscaler_irsa" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}",
      ]
    }
  }
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeInstanceTypes",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.eks_cluster_name}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.id}:autoscaling:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:autoScalingGroup:*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.eks_cluster_name}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.id}:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:nodegroup/${var.eks_cluster_name}/*"]

    actions = [
      "eks:DescribeNodegroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.eks_cluster_name}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.eks_cluster_name}-${var.helm_release_name}"
  path        = "/"
  description = "AWS IAM Policy for the Kubernetes service account ${var.k8s_namespace}:${var.k8s_service_account_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}
