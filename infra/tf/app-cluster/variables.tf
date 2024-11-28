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

variable "node_pool_name" {
  type        = string
  description = "Name of the node pool"  
}

# Container Registry
variable "container_registry_name" {
  type        = string
  description = "Name of the container registry"
}