variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region where the resources will be deployed"
}

variable "vm_username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}

# Container Registry
variable "container_registry_name" {
  type        = string
  description = "Name of the container registry"
}