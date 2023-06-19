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

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
}

variable "cluster_agent_namespace" {
  type        = string
  description = "The namespace where VESSL cluster agent will be installed"
}

variable "local_storage_class_name" {
  type        = string
  description = "The name of the local storage class to use for the cluster"
}

variable "vessl_agent_access_token" {
  type        = string
  description = "The access token for the VESSL cluster agent"
}
