# Lo que necesita un microservicio en el cluster: sus secretos desde Secret Manager
# y los topics de Kafka que consume y produce. Todo en su namespace.

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25, < 3.0"
    }
  }
}

provider "google" {
  project = "my-demo-project"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  namespace = "payments"
  labels = {
    app        = "payments-api"
    managed_by = "terraform"
  }
}

module "secrets" {
  source = "../../modules/k8s/external-secret-gsm"

  name                = "payments-api"
  namespace           = local.namespace
  project_id          = "my-demo-project"
  gsm_prefix          = "payments-api"
  eso_service_account = "external-secrets@my-demo-project.iam.gserviceaccount.com"
  keys                = ["DB_PASSWORD", "KAFKA_API_KEY", "KAFKA_API_SECRET", "JWT_SECRET"]
  labels              = local.labels
}

module "topic_orders_created" {
  source = "../../modules/k8s/kafka-topic-crossplane"

  name       = "orders-created"
  namespace  = local.namespace
  partitions = 12
  labels     = local.labels
}

module "topic_orders_dlq" {
  source = "../../modules/k8s/kafka-topic-crossplane"

  name         = "orders-created-dlq"
  namespace    = local.namespace
  partitions   = 3
  retention_ms = 1209600000 # 14 días
  labels       = local.labels
}

# Bloques env para pegar en el Deployment (uno por key, con secretKeyRef).
output "deployment_env" {
  value = module.secrets.env_from_secret
}

output "topics" {
  value = [module.topic_orders_created.topic_name, module.topic_orders_dlq.topic_name]
}
