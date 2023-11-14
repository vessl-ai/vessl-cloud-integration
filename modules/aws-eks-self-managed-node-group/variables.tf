variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version used in the control plane"
}

variable "cluster_endpoint" {
  type        = string
  description = "The endpoint of the cluster"
}

variable "cluster_certificate_authority_data" {
  type        = string
  description = "The certificate authority data for the cluster"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the node group"
  default     = null
}

variable "node_group_name" {
  type        = string
  description = "The name of the node group"
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of security group IDs to use for the node group"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone to use for the node group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet IDs to use for EKS control plane"
}

variable "iam_instance_profile_arn" {
  type        = string
  description = "The IAM instance profile ARN to use for the node group"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use for the node group"
}

variable "node_template_labels" {
  type        = map(any)
  description = "The additional node labels to apply to ASG launch template; Usually used for scale-to-zero features"
  default     = {}
}

variable "node_template_resources" {
  type        = map(any)
  description = "The additional node resource info to apply to ASG launch template; Usually used for scale-to-zero features"
  default     = {}
}

variable "taints" {
  type        = list(string)
  description = "The taints to apply to the node group"
  default     = []
}

variable "min_size" {
  type        = number
  description = "The minimum number of nodes to run in the node group"
  default     = 0
}

variable "max_size" {
  type        = number
  description = "The maximum number of nodes to run in the node group"
  default     = 3
}

variable "desired_size" {
  type        = number
  description = "The desired number of nodes to run in the node group"
  default     = 0
}

variable "instance_market_options" {
  type        = map(any)
  description = "The market (purchasing) option for the instances"
  default     = {}
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encryption of the EBS volume"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the node group"
  default     = {}
}
