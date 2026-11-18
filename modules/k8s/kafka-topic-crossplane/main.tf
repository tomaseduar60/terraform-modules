# Topic de Kafka como claim de Crossplane. El equipo de la app pide el topic en su
# namespace y la Composition (ver crossplane/) lo crea en el cluster de Kafka
# (Confluent Cloud o cualquier Kafka) con el ProviderConfig de la plataforma.

locals {
  topic_name = coalesce(var.topic_name, "${var.namespace}.${var.name}")
}

resource "kubernetes_manifest" "topic" {
  manifest = {
    apiVersion = "platform.example.io/v1alpha1"
    kind       = "KafkaTopic"
    metadata = {
      name      = var.name
      namespace = var.namespace
      labels    = var.labels
    }
    spec = {
      topicName         = local.topic_name
      partitions        = var.partitions
      replicationFactor = var.replication_factor
      retentionMs       = var.retention_ms
      cleanupPolicy     = var.cleanup_policy
      extraConfig       = var.extra_config
      compositionSelector = {
        matchLabels = {
          provider = var.composition_provider
        }
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "5m"
  }
}
