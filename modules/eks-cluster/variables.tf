variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
}

variable "cluster_iam_role_arn" {
  type        = string
  description = "The IAM role ARN of the cluster"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet IDs to use for EKS control plane"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Whether or not the Amazon EKS public API server endpoint is enabled"
  default     = true
}

variable "cluster_master_iam_users" {
  type        = list(string)
  description = "The IAM users to hold system:masters access. See also: https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html"
  default     = []
}

variable "cluster_master_iam_roles" {
  type        = map(string)
  description = "The IAM roles to hold system:masters access. See also: https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to the cluster resources"
  default     = {}
}
