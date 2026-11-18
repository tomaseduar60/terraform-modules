variable "name" {
  description = "Nombre del ExternalSecret (y del Secret de Kubernetes si no se indica target_secret_name)."
  type        = string
}

variable "namespace" {
  description = "Namespace de la aplicación."
  type        = string
}

variable "keys" {
  description = "Keys del Secret de Kubernetes, en formato de variable de entorno (ej. DB_PASSWORD)."
  type        = list(string)

  validation {
    condition     = alltrue([for k in var.keys : can(regex("^[A-Z][A-Z0-9_]*$", k))])
    error_message = "Las keys deben ser MAYÚSCULAS_CON_GUION_BAJO."
  }
}

variable "project_id" {
  description = "Proyecto GCP donde viven los secretos."
  type        = string
}

variable "gsm_prefix" {
  description = "Prefijo de los secretos en Secret Manager, normalmente el nombre de la app."
  type        = string
}

variable "create_gsm_secrets" {
  description = "Si es false, solo crea el ExternalSecret (los secretos ya existen en Secret Manager)."
  type        = bool
  default     = true
}

variable "eso_service_account" {
  description = "Email de la GSA que usa External Secrets Operator vía Workload Identity."
  type        = string
}

variable "secret_store_name" {
  description = "Nombre del SecretStore o ClusterSecretStore apuntando a Secret Manager."
  type        = string
  default     = "gcp-secret-manager"
}

variable "secret_store_kind" {
  description = "SecretStore o ClusterSecretStore."
  type        = string
  default     = "ClusterSecretStore"

  validation {
    condition     = contains(["SecretStore", "ClusterSecretStore"], var.secret_store_kind)
    error_message = "secret_store_kind debe ser SecretStore o ClusterSecretStore."
  }
}

variable "target_secret_name" {
  description = "Nombre del Secret de Kubernetes resultante. Por defecto, igual a name."
  type        = string
  default     = null
}

variable "refresh_interval" {
  description = "Cada cuánto ESO vuelve a leer Secret Manager."
  type        = string
  default     = "1h"
}

variable "eso_api_version" {
  description = "apiVersion de ExternalSecret según la versión de ESO instalada."
  type        = string
  default     = "external-secrets.io/v1"
}

variable "labels" {
  description = "Labels para los secretos y el ExternalSecret."
  type        = map(string)
  default     = {}
}
