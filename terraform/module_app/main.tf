resource "azurerm_container_app_environment" "cont_app_env" {
  name                = "cae-${var.app_name}-${var.environment}-${var.resource_group.location}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}
resource "azurerm_user_assigned_identity" "containerapp" {
  location            = var.resource_group.location
  name                = "containerappidentity-${var.app_name}-${var.environment}-${var.resource_group.location}"
  resource_group_name = var.resource_group.name
}
resource "azurerm_role_assignment" "containerapp" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
}

resource "azurerm_container_app" "ca" {
  name                         = "ca-${var.app_name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.cont_app_env.id
  resource_group_name          = var.resource_group.name
  revision_mode                = "Single"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }
  secret {
    name  = var.example_secret_name
    value = var.example_secret_value
  }
  template {
    container {
      name   = "${var.app_name}-${var.environment}-${var.resource_group.location}"
      image  = "${var.acr_login_server}/flask-server:0.0.0"
      cpu    = var.cpu
      memory = var.memory
      env {
        name        = "TESTSECRET"
        secret_name = var.example_secret_name
      }
    }
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
  depends_on = [
    azurerm_user_assigned_identity.containerapp
  ]
  ingress {
    external_enabled = true
    target_port      = 5000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

output "container_app_url" {
  value       = azurerm_container_app.ca.ingress[0].fqdn
  description = "The URL of the Azure Container App"
}

resource "azuread_application" "my_app" {
  display_name     = "app-${var.app_name}-${var.environment}-${var.resource_group.location}"
  sign_in_audience = "AzureADMyOrg"
  web {
    redirect_uris = [
      "https://${azurerm_container_app.ca.ingress[0].fqdn}/.auth/login/aad/callback",
      # "https://jep.example.fi/.auth/login/aad/callback",
      ]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azapi_resource_action" "my_app_auth" {
  type        = "Microsoft.App/containerApps/authConfigs@2024-03-01"
  resource_id = "${azurerm_container_app.ca.id}/authConfigs/current"
  method      = "PUT"
  body = {
    location = var.resource_group.location
    properties = {
      globalValidation = {
        redirectToProvider          = "azureactivedirectory"
        unauthenticatedClientAction = "RedirectToLoginPage"
      }
      identityProviders = {
        azureActiveDirectory = {
          registration = {
            clientId     = azuread_application.my_app.client_id
            openIdIssuer = "https://sts.windows.net/${var.tenant_id}/v2.0"
          }
          validation = {
            defaultAuthorizationPolicy = {
              allowedApplications = [
                azuread_application.my_app.client_id
              ]
            }
          }
        }
      }
      platform = {
        enabled = true
      }
    }
  }
}

resource "azurerm_dns_zone" "example" {
  name                = "example.fi"
  resource_group_name = var.resource_group.name
}

resource "azurerm_dns_txt_record" "example" {
  name                = "asuid.jep"
  resource_group_name = var.resource_group.name
  zone_name           = azurerm_dns_zone.example.name
  ttl                 = 300

  record {
    value = azurerm_container_app.ca.custom_domain_verification_id
  }
}
resource "azurerm_container_app_custom_domain" "example" {
  name                     = "jep.example.fi"
  container_app_id         = azurerm_container_app.ca.id
  certificate_binding_type = "SniEnabled"
  depends_on = [
    azurerm_user_assigned_identity.containerapp,
    azurerm_role_assignment.containerapp
  ]
}