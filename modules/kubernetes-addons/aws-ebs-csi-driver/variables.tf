variable "helm_values" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values. https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/charts/aws-ebs-csi-driver/Chart.yaml"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the cluster to install addon."
}

variable "oidc_issuer_url" {
  type        = string
  description = "The EKS cluster's OIDC issuer URL to use IAM roles in k8s service account."
}

variable "helm_repo_url" {
  type        = string
  default     = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  description = "The Helm repository URL for aws-ebs-csi-driver"
}

variable "helm_chart_name" {
  type        = string
  default     = "aws-ebs-csi-driver"
  description = "The Helm chart name for aws-ebs-csi-driver"
}

variable "helm_chart_version" {
  type        = string
  default     = "2.12.1"
  description = "The Helm chart version for aws-ebs-csi-driver"
}

variable "helm_release_name" {
  type        = string
  default     = "aws-ebs-csi-driver"
  description = "The Helm release name for aws-ebs-csi-driver"
}

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "kube-system"
  description = "The k8s namespace in which the aws-ebs-csi-driver service account has been created"
}

variable "k8s_service_account_name" {
  type        = string
  default     = "aws-ebs-csi-controller"
  description = "The k8s aws-ebs-csi-driver service account name"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to put on AWS resources (e.g. IAM role, owner, etc.)"
  default = {
    "Terraform" = "true"
  }
}
