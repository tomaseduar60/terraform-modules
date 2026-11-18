# Plataforma mínima en GCP: GKE privado + secretos + una API en Cloud Run.
# Valores de ejemplo: reemplazar project_id, red y subred por los propios.

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type    = string
  default = "my-demo-project"
}

variable "region" {
  type    = string
  default = "us-central1"
}

locals {
  labels = {
    env        = "demo"
    managed_by = "terraform"
  }
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes-demo"
  display_name = "Nodos GKE (demo)"
}

module "gke" {
  source = "../../modules/gcp/gke"

  name                 = "gke-demo"
  project_id           = var.project_id
  location             = var.region
  network              = "vpc-demo"
  subnetwork           = "snet-gke-demo"
  pods_range_name      = "pods"
  services_range_name  = "services"
  node_service_account = google_service_account.gke_nodes.email
  deletion_protection  = false

  master_authorized_networks = [
    { cidr_block = "203.0.113.0/24", display_name = "oficina" },
  ]

  node_pools = {
    general = { machine_type = "e2-standard-4", min_count = 1, max_count = 4 }
    spot = {
      machine_type = "e2-standard-4"
      min_count    = 0
      max_count    = 6
      spot         = true
      taints       = [{ key = "spot", value = "true", effect = "NO_SCHEDULE" }]
    }
  }

  labels = local.labels
}

module "secrets" {
  source = "../../modules/gcp/secret-manager"

  project_id = var.project_id
  secrets = {
    "api-db-password" = {}
    "api-jwt-secret"  = {}
  }
  labels = local.labels
}

module "api" {
  source = "../../modules/gcp/cloud-run"

  name       = "api-demo"
  project_id = var.project_id
  region     = var.region
  image      = "us-docker.pkg.dev/cloudrun/container/hello"

  env = {
    LOG_LEVEL = "info"
  }

  secret_env = {
    DB_PASSWORD = { secret = module.secrets.secret_names[0] }
    JWT_SECRET  = { secret = module.secrets.secret_names[1] }
  }

  allow_unauthenticated = true
  deletion_protection   = false
  labels                = local.labels
}

output "api_url" {
  value = module.api.uri
}

output "gke_cluster" {
  value = module.gke.name
}
