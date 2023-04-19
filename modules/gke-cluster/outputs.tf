output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  value = google_container_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate)
}
