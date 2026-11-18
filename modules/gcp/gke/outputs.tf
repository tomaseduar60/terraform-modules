output "name" {
  description = "Nombre del cluster."
  value       = google_container_cluster.this.name
}

output "endpoint" {
  description = "Endpoint del control plane."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "ca_certificate" {
  description = "CA del cluster (base64)."
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "workload_identity_pool" {
  description = "Pool de Workload Identity (<project>.svc.id.goog)."
  value       = google_container_cluster.this.workload_identity_config[0].workload_pool
}

output "node_pools" {
  description = "Nombres de los node pools creados."
  value       = [for np in google_container_node_pool.this : np.name]
}
