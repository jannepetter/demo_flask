data "azurerm_dns_zone" "example" {
  name                = "example.com"
  resource_group_name = var.resource_group.name
}

resource "azurerm_dns_txt_record" "validation" {
  name                = "asuid.staging" 
  zone_name           = data.azurerm_dns_zone.example.name
  resource_group_name = var.resource_group.name
  ttl                 = 300
  record {
    value = "joo"
  }
}

resource "azurerm_dns_cname_record" "custom_domain" {
  name                = "staging"
  zone_name           = data.azurerm_dns_zone.example.name
  resource_group_name = var.resource_group.name
  ttl                 = 300
  record              = var.container_app_url
}