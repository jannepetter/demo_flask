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

data "azurerm_subscription" "current" {
  subscription_id = var.SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.app_name}-${var.environment}-${var.location}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet_a" {
  name                = "rg-${var.app_name}-${var.environment}-${var.location}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "cae_subnet" {
  name                 = "cae-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_a.name
  address_prefixes     = ["10.1.0.0/22"]
}

data "azurerm_virtual_network" "vnet_b" {
  name                = "vnet-common-rg"
  resource_group_name = "common"
}

resource "azurerm_virtual_network_peering" "vneta_to_vnetb" {
  name                      = "vneta-to-vnetb"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_a.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet_b.id
}

resource "azurerm_virtual_network_peering" "vnetb_to_vneta" {
  name                      = "vnetb-to-vneta"
  resource_group_name       = data.azurerm_resource_group.common_rg.name
  virtual_network_name      = data.azurerm_virtual_network.vnet_b.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_a.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "db_link" {
  name                  = "db-link"
  resource_group_name   = data.azurerm_resource_group.common_rg.name
  private_dns_zone_name = "test-db-11.private.postgres.database.azure.com"
  virtual_network_id    = azurerm_virtual_network.vnet_a.id
}