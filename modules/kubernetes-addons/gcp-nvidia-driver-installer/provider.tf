data "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.region
}

data "google_client_config" "provider" {}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  load_config_file       = "false"
}

terraform {
  required_version = ">= 1.4"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
