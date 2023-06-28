resource "helm_release" "nvidia_gpu_operator" {
  repository = var.helm_repo_url
  chart      = var.helm_chart_name

  namespace        = var.k8s_namespace
  name             = var.helm_release_name
  version          = var.helm_chart_version
  create_namespace = var.k8s_create_namespace

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.k8s_service_account_name
  }

  set {
    name  = "toolkit.version"
    value = "v1.12.0-centos7"
  }

  dynamic "set" {
    for_each = var.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.helm_values_force_string
    content {
      name  = set.key
      value = set.value
      type  = "string"
    }
  }
}
