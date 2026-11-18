output "secret_name" {
  description = "Nombre del Secret de Kubernetes que crea ESO."
  value       = coalesce(var.target_secret_name, var.name)
}

output "gsm_secret_names" {
  description = "Secretos de Secret Manager por key. Hay que cargarles el valor fuera de Terraform."
  value       = local.remote_names
}

output "env_from_secret" {
  description = "Bloques env listos para el Deployment (una entrada secretKeyRef por key)."
  value = [
    for k in var.keys : {
      name = k
      valueFrom = {
        secretKeyRef = {
          name = coalesce(var.target_secret_name, var.name)
          key  = k
        }
      }
    }
  ]
}
