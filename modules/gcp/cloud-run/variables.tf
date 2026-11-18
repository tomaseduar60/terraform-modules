variable "name" {
  description = "Nombre del servicio."
  type        = string
}

variable "project_id" {
  description = "ID del proyecto GCP."
  type        = string
}

variable "region" {
  description = "Región de Cloud Run."
  type        = string
}

variable "image" {
  description = "Imagen del contenedor (idealmente con digest)."
  type        = string
}

variable "port" {
  description = "Puerto que expone el contenedor."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Límite de CPU."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Límite de memoria."
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Instancias mínimas (0 = escala a cero)."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Instancias máximas."
  type        = number
  default     = 5
}

variable "health_path" {
  description = "Ruta HTTP para startup y liveness probes."
  type        = string
  default     = "/healthz"
}

variable "env" {
  description = "Variables de entorno en texto plano (nada sensible)."
  type        = map(string)
  default     = {}
}

variable "secret_env" {
  description = "Variables de entorno desde Secret Manager: NOMBRE => { secret, version }."
  type = map(object({
    secret  = string
    version = optional(string, "latest")
  }))
  default = {}
}

variable "service_account_email" {
  description = "Service account existente. Si es null, se crea una dedicada."
  type        = string
  default     = null
}

variable "ingress" {
  description = "INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY o INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "allow_unauthenticated" {
  description = "Si es true, cualquiera puede invocar el servicio."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Evita que terraform destroy borre el servicio."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels del servicio."
  type        = map(string)
  default     = {}
}
