variable "helm_values" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/bitnami/external-dns"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster to install addon."
}

variable "helm_repo_url" {
  type        = string
  default     = "https://kubernetes-sigs.github.io/external-dns/"
  description = "The Helm repository URL for external-dns"
}

variable "helm_chart_name" {
  type        = string
  default     = "external-dns"
  description = "The Helm chart name for external-dns"
}

variable "helm_chart_version" {
  type        = string
  default     = "1.12.1"
  description = "The Helm chart version for external-dns"
}

variable "helm_release_name" {
  type        = string
  default     = "external-dns"
  description = "The Helm release name for external-dns"
}

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "kube-system"
  description = "The k8s namespace in which the external-dns service account has been created"
}

variable "k8s_service_account_name" {
  type        = string
  default     = "external-dns"
  description = "The k8s external-dns service account name"
}

variable "route53_hosted_zone_ids" {
  type        = list(string)
  description = "The list of Route53 hosted zone IDs to manage DNS records for"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to put on AWS resources (e.g. IAM role, owner, etc.)"
  default = {
    "terraform" = "true"
  }
}
