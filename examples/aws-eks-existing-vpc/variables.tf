variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "private_subnets" {
  type        = map(string)
  description = "The map of private subnets in VPC, keyed by subnet name and valued by subnet ID"
}

variable "public_subnets" {
  type        = map(string)
  description = "The map of app subnets in VPC, keyed by subnet name and valued by subnet ID"
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
