resource "kubernetes_namespace_v1" "vessl_cluster_agent" {
  metadata {
    name = var.k8s_namespace
    labels = {
      "name" = var.k8s_namespace
    }
  }

  timeouts {
    delete = "15m"
  }
}

resource "helm_release" "vessl_cluster_agent" {
  repository = var.helm_repo_url
  chart      = var.helm_chart_name

  namespace = var.k8s_namespace
  name      = var.helm_release_name
  version   = var.helm_chart_version

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.k8s_service_account_name
  }

  set {
    name  = "agent.apiServer"
    value = var.vessl_cluster_agent_option.vessl_api_server
  }

  set {
    name  = "agent.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "agent.accessToken"
    value = var.vessl_cluster_agent_option.vessl_agent_access_token
  }

  set {
    name  = "agent.logLevel"
    value = var.vessl_cluster_agent_option.log_level
  }

  set {
    name  = "agent.ingressEndpoint"
    value = var.vessl_cluster_agent_option.ingress_endpoint
  }

  set {
    name  = "agent.providerType"
    value = var.vessl_cluster_agent_option.provider_type
  }

  set {
    name  = "agent.localStorageClassName"
    value = var.vessl_cluster_agent_option.local_storage_class_name
  }

  set {
    name  = "agent.env"
    value = var.vessl_cluster_agent_option.environment
  }

  dynamic "set" {
    for_each = var.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    kubernetes_namespace_v1.vessl_cluster_agent
  ]
}
