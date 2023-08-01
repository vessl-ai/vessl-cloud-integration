variable "helm_values" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/bitnami/external-dns"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the cluster to install addon."
}

variable "eks_cluster_version" {
  type        = string
  description = "The version of the EKS cluster to install addon."
}

variable "oidc_issuer_url" {
  type        = string
  description = "The EKS cluster's OIDC issuer URL to use IAM roles in k8s service account."
}

variable "helm_repo_url" {
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
  description = "The Helm repository URL for cluster-autoscaler"
}

variable "helm_chart_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "The Helm chart name for cluster-autoscaler"
}

variable "helm_chart_version" {
  type        = string
  default     = "9.24.0"
  description = "The Helm chart version for cluster-autoscaler"
}

variable "helm_release_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "The Helm release name for cluster-autoscaler"
}

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "kube-system"
  description = "The k8s namespace in which the cluster-autoscaler service account has been created"
}

variable "k8s_node_selectors" {
  type = list(object({
    key   = string
    value = string
  }))
  default = []
  description = "Node selector for cluster-autoscaler, in label key-value pairs."
}

variable "k8s_service_account_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "The k8s cluster-autoscaler service account name"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to put on AWS resources (e.g. IAM role, owner, etc.)"
  default = {
    "Terraform" = "true"
  }
}
