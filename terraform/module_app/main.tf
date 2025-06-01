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
  scope                = var.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
}

data "azurerm_resource_group" "common_rg" {
  name = "common"
}
data "azurerm_key_vault" "fav" {
  name                = "prod-demoflask"
  resource_group_name = data.azurerm_resource_group.common_rg.name
}


resource "azurerm_role_assignment" "kv_user" {
  scope                = data.azurerm_key_vault.fav.id
  role_definition_name = "Key Vault Secrets User"
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
    server   = var.acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }
  template {
    container {
      name   = "${var.app_name}-${var.environment}-${var.resource_group.location}"
      image  = "${var.acr.login_server}/flask-server:latest"
      cpu    = var.cpu
      memory = var.memory
    }
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
  depends_on = [
    azurerm_user_assigned_identity.containerapp,
    azurerm_role_assignment.containerapp
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
      var.extra_redirect_uri,
    ]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azapi_resource_action" "my_app_auth" {
  type        = "Microsoft.App/containerApps/authConfigs@2025-01-01"
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
      login = {
        tokenStore = {
          enabled = true
        }
      }
    }
  }
}

resource "azapi_update_resource" "patch_env_var" {
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = azurerm_container_app.ca.id

  body = {
    properties = {
      template = {
        containers = [
          {
            env = [
              {
                name  = "AAD_CLIENT_ID"
                value = azuread_application.my_app.client_id
              },
              {
                name  = "ENV"
                value = "CLOUD"
              },
              {
                name  = "AZ_CA_CLIENT_ID"
                value = azurerm_user_assigned_identity.containerapp.client_id
              },
              {
                name  = "AZURE_TENANT_ID"
                value = var.tenant_id
              }
            ]
          }
        ]
      }
    }
  }

  depends_on = [azuread_application.my_app]
}