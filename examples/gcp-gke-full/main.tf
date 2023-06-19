resource "google_project_service" "google_container_api" {
  project            = var.gcp_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# -----------
# VPC Network
# -----------
module "gcp_vpc_network" {
  source = "github.com/vessl-ai/vessl-cloud-integration//modules/gcp-vpc-network?ref=0.1.1"

  gcp_project_id = var.gcp_project_id
  name           = var.network_name
  region         = var.region
}

# ---------------------------
# GKE Cluster (control plane)
# ---------------------------
module "gke_cluster" {
  depends_on = [google_project_service.google_container_api]
  source     = "github.com/vessl-ai/vessl-cloud-integration//modules/gke-cluster?ref=0.1.1"

  gcp_project_id  = var.gcp_project_id
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  location         = var.region
  vpc_network_name = module.gcp_vpc_network.network_name
}

# ---------------------------
# GKE Node Pool (worker node)
# ---------------------------
module "gke_node_pool_n1hm4_v100_1" {
  depends_on = [google_project_service.google_container_api]
  source     = "github.com/vessl-ai/vessl-cloud-integration//modules/gke-node-pool?ref=0.1.1"

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

# ----------------------------------------------------
# Kubernetes addons
# e.g. alb controller, autoscaler, cluster agent, etc.
# ----------------------------------------------------
module "addons_gcp_nvidia_driver_installer" {
  source = "../../modules/kubernetes-addons/gcp-nvidia-driver-installer"

  cluster_name = var.cluster_name
  region       = var.region

  depends_on = [module.gke_cluster]
}

module "addons_vessl_cluster_agent" {
  source        = "../../modules/kubernetes-addons/vessl-cluster-agent"
  cluster_name  = module.gke_cluster.cluster_name
  k8s_namespace = var.cluster_agent_namespace

  vessl_cluster_agent_option = {
    provider_type            = "gcp"
    vessl_agent_access_token = var.vessl_agent_access_token
    local_storage_class_name = var.local_storage_class_name
    environment              = "prod",
    ingress_endpoint         = "",
    log_level                = "info",
    vessl_api_server         = "https://api.vessl.ai"
  }

  helm_values = {
    "metricsExporters.dcgmExporter.enabled" = "false"
    "nvidia-device-plugin.enabled"          = "false"
    "nvidia-device-plugin.nfd.enabled"      = "false"
    "nvidia-device-plugin.gfd.enabled"      = "false"
    "localPathProvisioner.enabled"          = "false"
  }
}
