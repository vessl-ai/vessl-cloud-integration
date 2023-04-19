data "google_container_engine_versions" "gke_version" {
  project        = var.gcp_project_id
  location       = var.location
  version_prefix = endswith(var.cluster.version, ".") ? var.cluster_version : "${var.cluster_version}."
}

resource "google_container_cluster" "cluster" {
  depends_on = [google_project_service.google_container_api]

  network  = var.vpc_network_name
  name     = var.cluster_name
  location = var.location

  min_master_version       = data.google_container_engine_versions.gke_version.latest_master_version
  initial_node_count       = 1
  remove_default_node_pool = true

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  logging_service = "none"
}
