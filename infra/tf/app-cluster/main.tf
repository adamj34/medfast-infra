# Resource Group
data "azurerm_resource_group" "current" {
  name = var.resource_group_name
}

# Container Registry
data "azurerm_container_registry" "current" {
  name                = var.container_registry_name
  resource_group_name = data.azurerm_resource_group.current.name
}

# Virtual Network
resource "azurerm_virtual_network" "current" {
  name                = "app-vn"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.current.name
  address_space       = ["10.1.0.0/16"]
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.current.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Subnet for PostgreSQL
resource "azurerm_subnet" "postgres_subnet" {
  name                 = "postgres-subnet"
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.current.name
  address_prefixes     = ["10.1.2.0/24"]

  delegation {
    name = "psql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres_dns_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.current.name
}

# Virtual Network Link to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
  name                  = "postgres-dns-vnet-link"
  resource_group_name   = data.azurerm_resource_group.current.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.current.id

  depends_on = [azurerm_virtual_network.current]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.current.name
  dns_prefix          = "${var.app_name}-dns"
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name            = var.aks_node_pool_name
    node_count      = var.aks_node_number
    vm_size         = var.aks_vm_size
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  depends_on = [azurerm_subnet.aks_subnet]
}

# Assign AcrPull role to AKS cluster
resource "azurerm_role_assignment" "current" {
  principal_id                     = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.current.id
  skip_service_principal_aad_check = true
}

# Add NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  depends_on = [azurerm_kubernetes_cluster.default]
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "current" {
  name                   = var.postgres_server_name
  resource_group_name    = data.azurerm_resource_group.current.name
  location               = var.location
  zone                   = "1"
  administrator_login    = var.postgres_server_admin_login
  administrator_password = var.postgres_server_admin_passwd
  version                = "13"
  sku_name               = var.postgres_server_sku_name
  storage_mb             = var.postgres_server_storage_mb

  delegated_subnet_id           = azurerm_subnet.postgres_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres_dns_zone.id
  public_network_access_enabled = false

  depends_on = [
    # azurerm_subnet.postgres_subnet,
    azurerm_private_dns_zone_virtual_network_link.postgres_dns_link
  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.current.id
  value     = "pg_trgm"
}

resource "azurerm_postgresql_flexible_server_database" "current" {
  name      = var.postgres_server_app_db_name
  server_id = azurerm_postgresql_flexible_server.current.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

# resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
#   name             = "allow-azure-services"
#   server_id        = azurerm_postgresql_flexible_server.current.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "0.0.0.0"
# }
