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

output "app_subnet" {
  value = {
    id = azurerm_subnet.app_subnet.id
  }
  sensitive = true
}

output "cae" {
  value = {
    id = azurerm_container_app_environment.cont_app_env.id
  }
  sensitive = true
}

output "vnet" {
  value = {
    name = azurerm_virtual_network.vnet.name
  }
  sensitive = true
}