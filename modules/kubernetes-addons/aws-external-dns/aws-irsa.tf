data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# ----------------------------------------------------
# IAM Role to use for the external-dns service account
# ----------------------------------------------------
resource "aws_iam_role" "external_dns" {
  name               = "${var.eks_cluster_name}-${var.helm_release_name}-irsa"
  assume_role_policy = data.aws_iam_policy_document.external_dns_irsa.json
  description        = "AWS IAM Role for the Kubernetes service account ${var.k8s_namespace}:${var.k8s_service_account_name}"
  tags               = var.tags
}

# Assume role policy for IRSA
data "aws_iam_policy_document" "external_dns_irsa" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}",
      ]
    }
  }
}

# ------------------------------------
# IAM policy for external-dns IAM role
# ------------------------------------
data "aws_iam_policy_document" "external_dns" {
  statement {
    sid = "ChangeResourceRecordSets"

    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [for zone_id in var.route53_hosted_zone_ids : "arn:aws:route53:::hostedzone/${zone_id}"]
  }

  statement {
    sid = "ListResourceRecordSets"

    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "${var.eks_cluster_name}-${var.helm_release_name}"
  path        = "/"
  description = "AWS IAM Policy for the Kubernetes service account ${var.k8s_namespace}:${var.k8s_service_account_name}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
