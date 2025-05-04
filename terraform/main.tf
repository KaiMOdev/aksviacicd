data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.cluster_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.cluster_name}-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.cluster_name}-log"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name           = "system"
    vm_size        = var.system_pool_vm_size
    node_count     = var.system_pool_node_count
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.admin_group_object_ids
    tenant_id              = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled     = var.enable_azure_rbac
  }

  oidc_issuer_enabled       = var.enable_oidc_issuer
  workload_identity_enabled = var.enable_workload_identity

  azure_policy_enabled = false

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    dns_service_ip    = "10.10.2.10"
    service_cidr      = "10.10.2.0/24"
  }

  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled
  tags                    = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.system_pool_vm_size
  node_count            = 1
  mode                  = "User"
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id

  node_labels = {
    role = "user"
    env  = "dev"
  }

  node_taints = ["workload=user:NoSchedule"]
}