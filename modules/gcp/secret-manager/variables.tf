variable "project_id" {
  description = "ID del proyecto GCP."
  type        = string
}

variable "secrets" {
  description = "Secretos por nombre. accessors: miembros IAM con permiso de lectura (ej. serviceAccount:app@p.iam.gserviceaccount.com)."
  type = map(object({
    accessors         = optional(list(string), [])
    replica_locations = optional(list(string), [])
    labels            = optional(map(string), {})
  }))
}

variable "labels" {
  description = "Labels comunes a todos los secretos."
  type        = map(string)
  default     = {}
}
