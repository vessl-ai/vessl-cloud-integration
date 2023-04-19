variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "name" {
  type        = string
  description = "The name of the network"
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "Whether to create subnetworks automatically"
  default     = true
}

variable "subnets" {
  type        = map(string)
  description = "The subnets and CIDR blocks to create. Only used if auto_create_subnetworks is set to false"
  default = {
    "us-central1" = "10.128.0.0/20"
    "us-east5"    = "10.132.0.0/20"
  }
}
