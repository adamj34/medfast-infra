# General
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


# AKS
variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "aks_node_number" {
  type        = number
  description = "The number of nodes"
  default     = 1
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "aks_node_pool_name" {
  type        = string
  description = "Name of the node pool"
}

variable "aks_vm_size" {
  type        = string
  description = "Size of the VMs"
}


# Container Registry and Storage Account
variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "storage_container_name" {
  type        = string
  description = "Name of the storage container"
}

variable "container_registry_name" {
  type        = string
  description = "Name of the container registry"
}


# PostgreSQL Flexible Server
variable "postgres_server_name" {
  type        = string
  description = "Name of the PostgreSQL server"
}

variable "postgres_server_admin_login" {
  type        = string
  description = "Admin login for the PostgreSQL server"
}

variable "postgres_server_admin_passwd" {
  type        = string
  description = "Admin password for the PostgreSQL server"
  sensitive   = true
}

variable "postgres_server_sku_name" {
  type        = string
  description = "SKU name for the PostgreSQL server"
}

variable "postgres_server_app_db_name" {
  type        = string
  description = "Name of the application database"
}

variable "postgres_server_storage_mb" {
  type        = number
  description = "Storage size in MB"  
}
