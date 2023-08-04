data "aws_partition" "current" {}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = var.oidc_issuer_url
}


# --------------------------------------------------------------------
# IAM Role to use for the aws-load-balancer-controller service account
# --------------------------------------------------------------------
resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${var.eks_cluster_name}-${var.helm_release_name}-irsa"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_irsa.json
  description        = "AWS IAM Role for the Kubernetes service account ${var.k8s_namespace}:${var.k8s_service_account_name}"
  tags               = var.tags
}

# Assume role policy for IRSA
data "aws_iam_policy_document" "aws_load_balancer_controller_irsa" {
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

# ----------------------------------------------------
# IAM policy for aws-load-balancer-controller IAM role
# ----------------------------------------------------
# https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/v2.5.4/docs/install/iam_policy.json
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.eks_cluster_name}-${var.helm_release_name}"
  path        = "/"
  description = "AWS IAM Policy for the Kubernetes service account ${var.k8s_namespace}:${var.k8s_service_account_name}"
  policy      = file("${path.module}/aws_load_balancer_controller_iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

