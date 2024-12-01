data "azurerm_container_registry" "current" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.app_name}-dns"
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name            = var.node_pool_name
    node_count      = var.aks_node_number
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

}

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

  # Depends on the AKS cluster being ready
  depends_on = [azurerm_kubernetes_cluster.default]
}

# Postgres
resource "azurerm_postgresql_server" "current" {
  name                = "postgres-${var.app_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  administrator_login              = "user"
  administrator_login_password     = "secret123!"
  version                          = "11"
  ssl_enforcement_enabled          = true
  public_network_access_enabled    = false
}

resource "azurerm_postgresql_database" "current" {
  name                = "medfast"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.current.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

