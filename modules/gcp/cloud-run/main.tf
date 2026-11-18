# Servicio Cloud Run v2 con service account dedicada, secretos de Secret Manager
# montados como variables de entorno y acceso público opcional.

resource "google_service_account" "this" {
  count = var.service_account_email == null ? 1 : 0

  project      = var.project_id
  account_id   = substr("run-${var.name}", 0, 30)
  display_name = "Cloud Run ${var.name}"
}

locals {
  service_account = coalesce(var.service_account_email, try(google_service_account.this[0].email, null))
}

resource "google_cloud_run_v2_service" "this" {
  name                = var.name
  project             = var.project_id
  location            = var.region
  ingress             = var.ingress
  deletion_protection = var.deletion_protection
  labels              = var.labels

  template {
    service_account = local.service_account

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      ports {
        container_port = var.port
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle = true
      }

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_env
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }

      startup_probe {
        http_get {
          path = var.health_path
        }
        initial_delay_seconds = 0
        period_seconds        = 5
        failure_threshold     = 10
      }

      liveness_probe {
        http_get {
          path = var.health_path
        }
        period_seconds = 30
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Lectura de cada secreto usado, solo para la service account del servicio.
resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each = { for k, v in var.secret_env : k => v.secret }

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.service_account}"
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.allow_unauthenticated ? 1 : 0

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
