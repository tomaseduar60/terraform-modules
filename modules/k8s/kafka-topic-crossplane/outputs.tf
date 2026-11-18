output "topic_name" {
  description = "Nombre del topic en Kafka."
  value       = local.topic_name
}

output "claim" {
  description = "Referencia al claim de Crossplane."
  value       = "${var.namespace}/${var.name}"
}
