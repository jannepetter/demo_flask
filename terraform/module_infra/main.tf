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

resource "azurerm_container_app_environment" "cont_app_env" {
  name                     = "cae-${var.app_name}-${var.environment}-${azurerm_resource_group.rg.location}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  infrastructure_subnet_id = azurerm_subnet.app_subnet.id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 3
    minimum_count         = 0
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "flask-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "aca-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/23"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}
