data "azurerm_container_app" "ca" {
  name                = "ca-${var.app_name}-${var.environment}"
  resource_group_name = var.resource_group.name
}

data "azurerm_container_app_environment" "ca_env" {
  name                = var.ca_env_name
  resource_group_name = var.resource_group.name
}

resource "azurerm_container_app_custom_domain" "example" {
  name                     = var.custom_domain
  container_app_id         = data.azurerm_container_app.ca.id
  certificate_binding_type = "SniEnabled"
  lifecycle {
    ignore_changes = [certificate_binding_type, container_app_environment_certificate_id, container_app_id]
  }
}

resource "azapi_resource" "managed_certificate" {
  type      = "Microsoft.App/ManagedEnvironments/managedCertificates@2023-05-01"
  name      = var.cert_name
  parent_id = data.azurerm_container_app_environment.ca_env.id
  location  = var.resource_group.location
  body = {
    properties = {
      subjectName             = var.custom_domain,
      domainControlValidation = "CNAME"
    }
  }
  response_export_values = ["*"]
  depends_on             = [azurerm_container_app_custom_domain.example]
  lifecycle {
    ignore_changes = [parent_id]
  }
}

# binding that works
resource "null_resource" "run_az_cli" {
  provisioner "local-exec" {
    command = <<EOT
    az containerapp hostname bind \
      --name ${data.azurerm_container_app.ca.name} \
      --resource-group ${var.resource_group.name} \
      --hostname ${var.custom_domain} \
      --certificate ${var.cert_name} \
      -e ${data.azurerm_container_app_environment.ca_env.name}
    EOT
  }

  depends_on = [
    azapi_resource.managed_certificate
  ]
}

data "azurerm_traffic_manager_profile" "example" {
  name                = "flaskdemo"
  resource_group_name = "rg-global"
}

resource "azurerm_traffic_manager_external_endpoint" "example" {
  name                 = "tm-endpoint-ca-homma"
  profile_id           = data.azurerm_traffic_manager_profile.example.id
  always_serve_enabled = true
  target               = data.azurerm_container_app.ca.ingress[0].fqdn
}

