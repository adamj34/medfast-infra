# general 
app_name            = "medfast"
resource_group_name = "medfast-rg-prod"
location            = "northeurope"

# k8s
cluster_name    = "medfastAks"
aks_node_number = 1
k8s_version     = "1.29.2"
node_pool_name  = "medfast"

# container registry
container_registry_name = "medfastcr"