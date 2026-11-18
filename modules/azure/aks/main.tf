# Cluster AKS con OIDC issuer + Workload Identity, Azure CNI Overlay,
# RBAC de Entra ID (sin cuentas locales) y node pools de usuario opcionales.

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = coalesce(var.dns_prefix, var.name)
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  automatic_upgrade_channel = var.automatic_upgrade_channel
  node_os_upgrade_channel   = "NodeImage"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  local_account_disabled    = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_pool.vm_size
    vnet_subnet_id               = var.subnet_id
    auto_scaling_enabled         = true
    min_count                    = var.system_node_pool.min_count
    max_count                    = var.system_node_pool.max_count
    zones                        = var.zones
    only_critical_addons_enabled = true
    os_disk_type                 = "Ephemeral"
    os_disk_size_gb              = var.system_node_pool.os_disk_size_gb

    upgrade_settings {
      max_surge = "33%"
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = cidrhost(var.service_cidr, 10)
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [1]
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Saturday"
    start_time  = "03:00"
    duration    = 4
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  vnet_subnet_id        = var.subnet_id
  zones                 = var.zones
  mode                  = "User"
  auto_scaling_enabled  = true
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  priority              = each.value.spot ? "Spot" : "Regular"
  eviction_policy       = each.value.spot ? "Delete" : null
  spot_max_price        = each.value.spot ? -1 : null
  node_labels           = each.value.labels
  node_taints           = each.value.taints
  tags                  = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
