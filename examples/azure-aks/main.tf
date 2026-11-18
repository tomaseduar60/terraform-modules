# AKS con Workload Identity y un node pool spot para cargas tolerantes a interrupciones.

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-aks-demo"
  location = "eastus2"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-aks-demo"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "nodes" {
  name                 = "snet-nodes"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.0.0/22"]
}

module "aks" {
  source = "../../modules/azure/aks"

  name                = "aks-demo"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.nodes.id

  user_node_pools = {
    apps = { min_count = 1, max_count = 5 }
    spot = {
      min_count = 0
      max_count = 10
      spot      = true
      taints    = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
    }
  }

  tags = {
    env        = "demo"
    managed_by = "terraform"
  }
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}
