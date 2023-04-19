provider "google" {
  project = "buoyant-aloe-380111"
  region  = "us-central1"
}

data "google_client_config" "provider" {}

provider "kubectl" {
  host                   = "https://${module.gke_cluster.cluster_endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
}

terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  backend "gcs" {
    # Remaining configuration omitted - see terraform.tfbackend
  }
}
