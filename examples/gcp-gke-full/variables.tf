variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network"
}
