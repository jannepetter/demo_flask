output "container_app_fqdn" {
  value = azurerm_container_app.ca.ingress[0].fqdn
}