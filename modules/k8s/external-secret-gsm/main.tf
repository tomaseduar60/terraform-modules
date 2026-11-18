# Un secreto de aplicación de punta a punta:
#   1. crea en Secret Manager un secreto por cada key (sin valor),
#   2. le da lectura a la identidad de External Secrets Operator,
#   3. crea el ExternalSecret que arma un único Secret de Kubernetes con todas las keys.
# El Deployment después consume cada key con secretKeyRef.

locals {
  # Nombre en Secret Manager: <prefix>-<key en kebab-case>. Ej: payments-api-db-password
  remote_names = {
    for k in var.keys : k => lower(replace("${var.gsm_prefix}-${k}", "_", "-"))
  }
}

resource "google_secret_manager_secret" "this" {
  for_each = var.create_gsm_secrets ? local.remote_names : {}

  project   = var.project_id
  secret_id = each.value
  labels    = merge(var.labels, { namespace = var.namespace })

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "eso" {
  for_each = var.create_gsm_secrets ? local.remote_names : {}

  project   = var.project_id
  secret_id = google_secret_manager_secret.this[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.eso_service_account}"
}

resource "kubernetes_manifest" "external_secret" {
  manifest = {
    apiVersion = var.eso_api_version
    kind       = "ExternalSecret"
    metadata = {
      name      = var.name
      namespace = var.namespace
      labels    = var.labels
    }
    spec = {
      refreshInterval = var.refresh_interval
      secretStoreRef = {
        kind = var.secret_store_kind
        name = var.secret_store_name
      }
      target = {
        name           = coalesce(var.target_secret_name, var.name)
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        for k, remote in local.remote_names : {
          secretKey = k
          remoteRef = {
            key     = remote
            version = "latest"
          }
        }
      ]
    }
  }

  depends_on = [google_secret_manager_secret_iam_member.eso]
}
