# Secretos de Secret Manager SIN valores: Terraform crea el contenedor y los permisos,
# el valor se carga fuera de Terraform (gcloud o pipeline) para que nunca quede en el state.

resource "google_secret_manager_secret" "this" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.key
  labels    = merge(var.labels, each.value.labels)

  replication {
    dynamic "auto" {
      for_each = length(each.value.replica_locations) == 0 ? [1] : []
      content {}
    }

    dynamic "user_managed" {
      for_each = length(each.value.replica_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = each.value.replica_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }
}

locals {
  accessors = merge([
    for secret, cfg in var.secrets : {
      for member in cfg.accessors : "${secret}|${member}" => { secret = secret, member = member }
    }
  ]...)
}

resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each = local.accessors

  project   = var.project_id
  secret_id = google_secret_manager_secret.this[each.value.secret].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}
