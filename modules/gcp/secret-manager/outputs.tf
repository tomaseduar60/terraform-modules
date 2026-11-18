output "secret_ids" {
  description = "IDs completos de los secretos, por nombre."
  value       = { for k, s in google_secret_manager_secret.this : k => s.id }
}

output "secret_names" {
  description = "Nombres cortos de los secretos."
  value       = keys(google_secret_manager_secret.this)
}
