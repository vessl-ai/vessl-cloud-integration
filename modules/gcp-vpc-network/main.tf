resource "google_compute_network" "this" {
  project = var.gcp_project_id
  name    = var.name
}

resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets

  name          = "${var.cluster_name}-subnet-${each.key}"
  network       = google_compute_network.this.name
  region        = var.google_region
  ip_cidr_range = each.value
}

resource "google_compute_firewall" "allow-k8s-nodeport" {
  name    = "${var.cluster_name}-allow-k8s-nodeport"
  network = google_compute_network.this.self_link

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}
