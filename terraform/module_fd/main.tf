resource "azurerm_cdn_frontdoor_profile" "example" {
  name                = "example-frontdoor-profile"
  resource_group_name = var.resource_group.name
  sku_name            = "Standard_AzureFrontDoor" # Or Premium_AzureFrontDoor
}

resource "azurerm_cdn_frontdoor_endpoint" "example" {
  name                     = "example-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id
}

resource "azurerm_cdn_frontdoor_origin_group" "example" {
  name                = "example-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id
  session_affinity_enabled = false
  health_probe {
    protocol = "Https"
    path     = "/hello"
    interval_in_seconds = 30
  }
  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "example" {
  name                  = "example-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id
  enabled               = true

  certificate_name_check_enabled = false

  host_name             = var.container_app_fqdn
  origin_host_header    = var.container_app_fqdn 
  http_port             = 80
  https_port            = 443
  priority              = 1
  weight                = 1
}

resource "azurerm_cdn_frontdoor_route" "example" {
  name                          = "example-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.example.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.example.id]
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

}
