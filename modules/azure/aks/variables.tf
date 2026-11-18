variable "name" {
  description = "Nombre del cluster."
  type        = string
}

variable "location" {
  description = "Región de Azure."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group donde se crea el cluster."
  type        = string
}

variable "dns_prefix" {
  description = "Prefijo DNS del API server. Por defecto, el nombre del cluster."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes. null = la por defecto de AKS."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Free, Standard (SLA) o Premium."
  type        = string
  default     = "Standard"
}

variable "automatic_upgrade_channel" {
  description = "patch, rapid, stable, node-image o none."
  type        = string
  default     = "patch"
}

variable "subnet_id" {
  description = "ID de la subred de los nodos."
  type        = string
}

variable "zones" {
  description = "Zonas de disponibilidad."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "pod_cidr" {
  description = "CIDR de pods (overlay, no consume IPs de la VNet)."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "CIDR de services. El DNS del cluster usa la IP .10."
  type        = string
  default     = "10.0.0.0/16"
}

variable "admin_group_object_ids" {
  description = "Object IDs de grupos de Entra ID con rol de admin del cluster."
  type        = list(string)
  default     = []
}

variable "system_node_pool" {
  description = "Configuración del node pool de sistema."
  type = object({
    vm_size         = optional(string, "Standard_D4ds_v5")
    min_count       = optional(number, 2)
    max_count       = optional(number, 4)
    os_disk_size_gb = optional(number, 128)
  })
  default = {}
}

variable "user_node_pools" {
  description = "Node pools de usuario por nombre (máx. 12 caracteres, minúsculas)."
  type = map(object({
    vm_size   = optional(string, "Standard_D4ds_v5")
    min_count = optional(number, 1)
    max_count = optional(number, 5)
    spot      = optional(bool, false)
    labels    = optional(map(string), {})
    taints    = optional(list(string), [])
  }))
  default = {}
}

variable "log_analytics_workspace_id" {
  description = "Workspace de Log Analytics para Container Insights. null = desactivado."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags de Azure."
  type        = map(string)
  default     = {}
}
