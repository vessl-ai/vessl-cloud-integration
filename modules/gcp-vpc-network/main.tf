resource "google_compute_network" "this" {
  project                 = var.gcp_project_id
  name                    = var.name
  auto_create_subnetworks = var.auto_create_subnetworks
}

resource "google_compute_subnetwork" "subnet" {
  for_each = var.auto_create_subnetworks ? {} : var.subnets

  name          = "${var.name}-subnet-${each.key}"
  network       = google_compute_network.this.name
  region        = var.region
  ip_cidr_range = each.value
}

resource "google_compute_firewall" "allow-k8s-nodeport" {
  name    = "${var.name}-allow-k8s-nodeport"
  network = google_compute_network.this.self_link

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}
