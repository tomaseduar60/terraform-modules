variable "name" {
  description = "Nombre del cluster."
  type        = string
}

variable "project_id" {
  description = "ID del proyecto GCP."
  type        = string
}

variable "location" {
  description = "Región (cluster regional) o zona (cluster zonal)."
  type        = string
}

variable "network" {
  description = "Self link o nombre de la VPC."
  type        = string
}

variable "subnetwork" {
  description = "Self link o nombre de la subred."
  type        = string
}

variable "pods_range_name" {
  description = "Nombre del rango secundario de la subred para pods."
  type        = string
}

variable "services_range_name" {
  description = "Nombre del rango secundario de la subred para services."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR /28 del control plane."
  type        = string
  default     = "172.16.0.0/28"
}

variable "private_endpoint" {
  description = "Si es true, el control plane solo es accesible por IP privada."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "Redes autorizadas para llegar al control plane."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "Canal de versiones de GKE: RAPID, REGULAR o STABLE."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel debe ser RAPID, REGULAR o STABLE."
  }
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento recurrente (RFC 5545)."
  type = object({
    start_time = string
    end_time   = string
    recurrence = string
  })
  default = {
    start_time = "2024-01-01T03:00:00Z"
    end_time   = "2024-01-01T07:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
  }
}

variable "node_service_account" {
  description = "Email de la service account de los nodos (mínimos privilegios, no la default de Compute)."
  type        = string
}

variable "node_pools" {
  description = "Node pools a crear, por nombre."
  type = map(object({
    machine_type = optional(string, "e2-standard-4")
    disk_size_gb = optional(number, 100)
    min_count    = optional(number, 1)
    max_count    = optional(number, 3)
    spot         = optional(bool, false)
    labels       = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {
    default = {}
  }
}

variable "deletion_protection" {
  description = "Evita que terraform destroy borre el cluster."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels para el cluster y los nodos."
  type        = map(string)
  default     = {}
}
