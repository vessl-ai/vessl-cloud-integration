variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "location" {
  type        = string
  description = "The location (region or zone) for the cluster"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
}

variable "preemptible" {
  type        = bool
  description = "Whether to use preemptible nodes"
  default     = false
}

variable "machine_type" {
  type        = string
  description = "The machine type to use for the nodes"
  default     = "e2-highmem-2"
}

variable "min_node_count" {
  type        = number
  description = "The minimum number of nodes to use for the node pool"
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "The maximum number of nodes to use for the node pool"
  default     = 1
}

variable "gpu" {
  type = object(
    {
      type           = string
      count          = string
      partition_size = optional(string)
      sharing_config = optional(object(
        {
          gpu_sharing_strategy       = string
          max_shared_clients_per_gpu = string
        }
      ))
    }
  )
  description = <<EOT
    gpu = {
      type           = "Type of GPU, e.g. nvidia-tesla-v100"
      count          = "Number of GPUs, e.g. 1"
      partition_size = "Size of MIG partitions to create on the GPU. Valid values are described in the NVIDIA mig user guide. e.g. 1g.5gb"
      sharing_config = {
        gpu_sharing_strategy = "The strategy to use for sharing GPUs. e.g. TIME_SHARING"
        max_shared_clients_per_gpu = "The maximum number of clients that can share a GPU. e.g. 2"
      }
    }
  EOT
  default     = {}
}
