output "uri" {
  description = "URL del servicio."
  value       = google_cloud_run_v2_service.this.uri
}

output "service_account_email" {
  description = "Service account con la que corre el servicio."
  value       = local.service_account
}

output "latest_revision" {
  description = "Última revisión creada."
  value       = google_cloud_run_v2_service.this.latest_created_revision
}
