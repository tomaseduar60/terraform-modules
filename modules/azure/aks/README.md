# azure/aks

Cluster AKS listo para producción: OIDC issuer + Workload Identity, cuentas locales desactivadas (acceso solo por Entra ID con Azure RBAC), Azure CNI Overlay con Cilium como data plane y network policy, CSI de Key Vault con rotación de secretos y upgrades automáticos dentro de una ventana de mantenimiento.

El pool de sistema queda solo para addons críticos. Las aplicaciones van en `user_node_pools`, que pueden ser spot.

## Uso

```hcl
module "aks" {
  source = "github.com/tomaseduar60/terraform-modules//modules/azure/aks?ref=v1.0.0"

  name                   = "aks-prd"
  location               = "eastus2"
  resource_group_name    = "rg-aks-prd"
  subnet_id              = azurerm_subnet.nodes.id
  admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]

  user_node_pools = {
    apps = { min_count = 2, max_count = 8 }
  }
}
```

## Entradas

| Nombre | Descripción | Tipo | Default | Requerida |
|---|---|---|---|:---:|
| `name` | Nombre del cluster. | `string` | - | sí |
| `location` | Región de Azure. | `string` | - | sí |
| `resource_group_name` | Resource group donde se crea el cluster. | `string` | - | sí |
| `dns_prefix` | Prefijo DNS del API server. Por defecto, el nombre del cluster. | `string` | `null` | no |
| `kubernetes_version` | Versión de Kubernetes. null = la por defecto de AKS. | `string` | `null` | no |
| `sku_tier` | Free, Standard (SLA) o Premium. | `string` | `"Standard"` | no |
| `automatic_upgrade_channel` | patch, rapid, stable, node-image o none. | `string` | `"patch"` | no |
| `subnet_id` | ID de la subred de los nodos. | `string` | - | sí |
| `zones` | Zonas de disponibilidad. | `list(string)` | `["1", "2", "3"]` | no |
| `pod_cidr` | CIDR de pods (overlay, no consume IPs de la VNet). | `string` | `"10.244.0.0/16"` | no |
| `service_cidr` | CIDR de services. El DNS del cluster usa la IP .10. | `string` | `"10.0.0.0/16"` | no |
| `admin_group_object_ids` | Object IDs de grupos de Entra ID con rol de admin del cluster. | `list(string)` | `[]` | no |
| `system_node_pool` | Configuración del node pool de sistema. | `object` | `{}` | no |
| `user_node_pools` | Node pools de usuario por nombre (máx. 12 caracteres, minúsculas). | `map(object)` | `{}` | no |
| `log_analytics_workspace_id` | Workspace de Log Analytics para Container Insights. null = desactivado. | `string` | `null` | no |
| `tags` | Tags de Azure. | `map(string)` | `{}` | no |

## Salidas

| Nombre | Descripción |
|---|---|
| `id` | ID del cluster. |
| `name` | Nombre del cluster. |
| `oidc_issuer_url` | URL del OIDC issuer, para federar identidades (Workload Identity). |
| `kubelet_identity_object_id` | Object ID de la identidad del kubelet (por ejemplo, para AcrPull). |
| `node_resource_group` | Resource group administrado por AKS. |
