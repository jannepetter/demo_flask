data "azurerm_resource_group" "rg" {
  name = "flask-app"
}
data "azurerm_container_registry" "acr" {
  name                = "flaskdemohommat"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "fav" {
  name                = "flask-app-vault"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "example_secret" {
  name         = "testjuttu"
  key_vault_id = data.azurerm_key_vault.fav.id
}

data "azurerm_subscription" "current" {
  subscription_id = var.SUBSCRIPTION_ID
}
