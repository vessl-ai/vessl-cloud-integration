data "aws_region" "current" {}

resource "helm_release" "cluster_autoscaler" {
  repository = var.helm_repo_url
  chart      = var.helm_chart_name

  namespace = var.k8s_namespace
  name      = var.helm_release_name
  version   = var.helm_chart_version

  values = [templatefile("${path.module}/values.yaml", {
    aws_region       = data.aws_region.current.name
    eks_cluster_name = var.eks_cluster_name
    image_tag        = "v${var.eks_cluster_version}.0"
    node_selectors   = var.k8s_node_selectors
  })]

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = var.k8s_service_account_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }

  dynamic "set" {
    for_each = var.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
