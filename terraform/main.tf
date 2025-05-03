resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-demo"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks"
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemoprefix"

  default_node_pool {
    name                = "system"
    node_count          = 1
    min_count           = 1
    max_count           = 3
    enable_auto_scaling = true
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = azurerm_subnet.aks.id
  }

  node_pool {
    name                = "user"
    vm_size             = "Standard_B2s"
    node_count          = 1
    min_count           = 1
    max_count           = 3
    enable_auto_scaling = true
    mode                = "User"
    vnet_subnet_id      = azurerm_subnet.aks.id
    node_labels = {
      role = "user"
      env  = "dev"
    }
    node_taints = [
      "workload=user:NoSchedule"
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = [var.admin_group_object_id]
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    dns_service_ip     = "10.10.2.10"
    service_cidr       = "10.10.2.0/24"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
    }
  }

  sku_tier = "Free"
  private_cluster_enabled  = false
  tags                     = var.tags
}
