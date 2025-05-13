resource "azurerm_subnet" "gateway_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "appgw_ip" {
  name                = "appgw-pip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.gateway_subnet.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = [var.container_app_fqdn]
  }

  backend_http_settings {
    name                                = "backendSettings"
    port                                = 5000
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    cookie_based_affinity               = "Disabled"
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routingRule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "backendSettings"
  }
}