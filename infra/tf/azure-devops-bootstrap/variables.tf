variable "app_name" {
  type        = string
  description = "Name of the application"
  default     = "medfast"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "medfast-pipeline-runners"
}

variable "location" {
  type        = string
  description = "Azure region where the resources will be deployed"
  default     = "northeurope"
}

variable "vm_username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}
