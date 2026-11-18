output "id" {
  description = "ID del cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Nombre del cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "oidc_issuer_url" {
  description = "URL del OIDC issuer, para federar identidades (Workload Identity)."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  description = "Object ID de la identidad del kubelet (por ejemplo, para AcrPull)."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "node_resource_group" {
  description = "Resource group administrado por AKS."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}
