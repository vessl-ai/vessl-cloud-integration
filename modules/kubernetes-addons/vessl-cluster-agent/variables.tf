variable "helm_values" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the cluster to install addon."
}

variable "helm_repo_url" {
  type        = string
  default     = "https://vessl-ai.github.io/cluster-resources/helm-chart"
  description = "The Helm repository URL for vessl-cluster-agent"
}

variable "helm_chart_name" {
  type        = string
  default     = "cluster-resources"
  description = "The Helm chart name for vessl-cluster-agent"
}

variable "helm_chart_version" {
  type        = string
  default     = "0.1.34"
  description = "The Helm chart version for vessl-cluster-agent"
}

variable "helm_release_name" {
  type        = string
  default     = "cluster-resources"
  description = "The Helm release name for vessl-cluster-agent"
}

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "vessl"
  description = "The k8s namespace in which the vessl-cluster-agent service account has been created"
}

variable "k8s_service_account_name" {
  type        = string
  default     = "vessl-cluster-resource"
  description = "The k8s vessl-cluster-agent service account name"
}

variable "vessl_cluster_agent_option" {
  type = object({
    vessl_api_server         = string,
    vessl_agent_access_token = string,
    log_level                = string,
    ingress_endpoint         = string,
    provider_type            = string,
    local_storage_class_name = string,
    environment              = string
  })
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to put on AWS resources (e.g. IAM role, owner, etc.)"
  default = {
    "Terraform" = "true"
  }
}
