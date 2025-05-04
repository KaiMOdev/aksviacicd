variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure region for resources."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-aks-demo"
}

variable "cluster_name" {
  type        = string
  default     = "aks-demo"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    owner       = "cloudcrusader"
  }
}

variable "system_pool_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "system_pool_node_count" {
  type    = number
  default = 1
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "enable_azure_rbac" {
  type    = bool
  default = true
}

variable "enable_oidc_issuer" {
  type    = bool
  default = true
}

variable "enable_workload_identity" {
  type    = bool
  default = true
}

variable "admin_group_object_ids" {
  type        = list(string)
  default     = []
  description = "List of Azure AD Group object IDs for cluster admin roles"
}
