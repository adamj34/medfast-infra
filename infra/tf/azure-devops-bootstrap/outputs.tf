output "storage_account_primary_access_key" {
  value     = azurerm_storage_account.tfstate.primary_access_key
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}