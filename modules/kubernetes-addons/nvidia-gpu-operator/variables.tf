variable "helm_values" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values.https://github.com/NVIDIA/gpu-operator/blob/master/deployments/gpu-operator/Chart.yaml"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the cluster to install addon."
}

variable "helm_repo_url" {
  type        = string
  default     = "https://nvidia.github.io/gpu-operator"
  description = "The Helm repository URL for nvidia-gpu-operator"
}

variable "helm_chart_name" {
  type        = string
  default     = "gpu-operator"
  description = "The Helm chart name for nvidia-gpu-operator"
}

variable "helm_chart_version" {
  type        = string
  default     = "22.9.2"
  description = "The Helm chart version for nvidia-gpu-operator"
}

variable "helm_release_name" {
  type        = string
  default     = "gpu-operator"
  description = "The Helm release name for nvidia-gpu-operator"
}

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "nvidia-gpu-operator"
  description = "The k8s namespace in which the nvidia-gpu-operator service account has been created"
}

variable "k8s_service_account_name" {
  type        = string
  default     = "nvidia-gpu-operator"
  description = "The k8s nvidia-gpu-operator service account name"
}

variable "is_aws" {
  type    = bool
  default = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to put on AWS resources (e.g. IAM role, owner, etc.)"
  default = {
    "Terraform" = "true"
  }
}
