provider "google" {
  project = "buoyant-aloe-380111"
  region  = "us-central1"
}

terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  backend "gcs" {
    # Remaining configuration omitted - see terraform.tfbackend
  }
}
