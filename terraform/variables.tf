variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    owner       = "cloudcrusader"
  }
}

variable "admin_group_object_id" {
  type        = string
  description = "Azure AD group object ID voor cluster admin toegang"
}
