data "google_container_engine_versions" "gke_version" {
  project  = var.gcp_project_id
  location = var.location

  version_prefix = endswith(var.cluster.version, ".") ? var.cluster_version : "${var.cluster_version}."
}

resource "google_container_node_pool" "this" {
  project  = var.gcp_project_id
  location = var.location

  name    = var.name
  cluster = var.cluster_name
  version = data.google_container_engine_versions.gke_version.latest_master_version

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    image_type   = "COS_CONTAINERD"

    gcfs_config {
      enabled = true
    }

    labels = {
      "vessl.ai/node-type" = var.machine_type
      "vessl.ai/gpu-type"  = length(var.gpu) > 0 ? var.gpu.type : null
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    guest_accelerator = [
      {
        type               = var.gpu.type
        count              = var.gpu.count
        gpu_partition_size = var.gpu.partition_size
        gpu_sharing_config = var.gpu.sharing_config
      }
    ]
  }

  initial_node_count = var.min_node_count
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
}
