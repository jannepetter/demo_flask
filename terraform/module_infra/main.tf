data "azurerm_resource_group" "common_rg" {
  name = "common"
}
data "azurerm_container_registry" "acr" {
  name                = "demoflask"
  resource_group_name = data.azurerm_resource_group.common_rg.name
}

data "azurerm_key_vault" "fav" {
  name                = "prod-demoflask"
  resource_group_name = data.azurerm_resource_group.common_rg.name
}

data "azurerm_key_vault_secret" "example_secret" {
  name         = "testjuttu"
  key_vault_id = data.azurerm_key_vault.fav.id
}

data "azurerm_subscription" "current" {
  subscription_id = var.SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.app_name}-${var.environment}-${var.location}"
  location = var.location
}
