resource "google_project_service" "google_container_api" {
  project            = var.gcp_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

module "gcp_vpc_network" {
  source = "../../modules/gcp-vpc-network"

  gcp_project_id = var.gcp_project_id
  name           = var.network_name
  region         = var.region
}

module "gke_cluster" {
  depends_on = [google_project_service.google_container_api]
  source     = "../../modules/gke-cluster"

  gcp_project_id  = var.gcp_project_id
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  location         = var.region
  vpc_network_name = module.gcp_vpc_network.network_name
}

module "gke_node_pool_n1hm4_v100_1" {
  depends_on = [google_project_service.google_container_api]
  source     = "../../modules/gke-node-pool"

  gcp_project_id = var.gcp_project_id
  location       = var.region

  name            = "${module.gke_cluster.cluster_name}-n1hm4-v100-1"
  cluster_name    = module.gke_cluster.cluster_name
  cluster_version = var.cluster_version

  preemptible    = true
  machine_type   = "n1-highmem-4"
  min_node_count = 1
  max_node_count = 5
  gpu = {
    type           = "nvidia-tesla-v100"
    count          = 1
    partition_size = null
    sharing_config = null
  }
}

