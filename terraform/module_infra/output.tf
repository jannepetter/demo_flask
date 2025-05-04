output "resource_group" {
  value = {
    location = azurerm_resource_group.rg.location
    name     = azurerm_resource_group.rg.name
  }
  sensitive = true
}

output "acr" {
  value = {
    id           = data.azurerm_container_registry.acr.id
    login_server = data.azurerm_container_registry.acr.login_server
  }
  sensitive = true
}

output "example_secret" {
  value = {
    name  = data.azurerm_key_vault_secret.example_secret.name
    value = data.azurerm_key_vault_secret.example_secret.value
  }
  sensitive = true
}

output "subscription" {
  value = {
    tenant_id = data.azurerm_subscription.current.tenant_id
  }
  sensitive = true
}