variable "name" {
  description = "Nombre del claim en Kubernetes."
  type        = string
}

variable "namespace" {
  description = "Namespace del equipo dueño del topic."
  type        = string
}

variable "topic_name" {
  description = "Nombre real del topic en Kafka. Por defecto, <namespace>.<name>."
  type        = string
  default     = null
}

variable "partitions" {
  description = "Cantidad de particiones (solo se puede aumentar)."
  type        = number
  default     = 6

  validation {
    condition     = var.partitions >= 1 && var.partitions <= 100
    error_message = "partitions debe estar entre 1 y 100."
  }
}

variable "replication_factor" {
  description = "Factor de replicación. Confluent Cloud exige 3."
  type        = number
  default     = 3
}

variable "retention_ms" {
  description = "Retención en milisegundos. -1 = infinita."
  type        = number
  default     = 604800000 # 7 días
}

variable "cleanup_policy" {
  description = "delete, compact o compact,delete."
  type        = string
  default     = "delete"

  validation {
    condition     = contains(["delete", "compact", "compact,delete"], var.cleanup_policy)
    error_message = "cleanup_policy debe ser delete, compact o compact,delete."
  }
}

variable "extra_config" {
  description = "Configuración adicional del topic (ej. max.message.bytes)."
  type        = map(string)
  default     = {}
}

variable "composition_provider" {
  description = "Label provider de la Composition a usar (ej. confluent)."
  type        = string
  default     = "confluent"
}

variable "labels" {
  description = "Labels del claim."
  type        = map(string)
  default     = {}
}
