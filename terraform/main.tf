provider "azurerm" {
  features {}
  subscription_id = var.SUBSCRIPTION_ID
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.27.0"
    }
  }
}

data "azurerm_resource_group" "rg" {
  name     = "flask-app"
}
data "azurerm_container_registry" "acr" {
  name                = "flaskdemohommat"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_container_app_environment" "cont_app_env" {
  name                       = "flask-app-cont-env"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "fav" {
  name                = "flask-app-vault"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "example_secret" {
  name         = "testjuttu"
  key_vault_id = data.azurerm_key_vault.fav.id
}

resource "azurerm_user_assigned_identity" "containerapp" {
  location            = data.azurerm_resource_group.rg.location
  name                = "containerappidentity"
  resource_group_name = data.azurerm_resource_group.rg.name
}
resource "azurerm_role_assignment" "containerapp" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
}

resource "azurerm_container_app" "ca" {
  name                         = "flask-container-app"
  container_app_environment_id = azurerm_container_app_environment.cont_app_env.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }
  
  registry {
    server = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }
  secret {
    name = data.azurerm_key_vault_secret.example_secret.name
    value = data.azurerm_key_vault_secret.example_secret.value
  }
  template {
    container {
      name   = "demo-flask"
      image  = "${data.azurerm_container_registry.acr.login_server}/${var.IMAGE_NAME}:0.0.0"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name = "TESTSECRET"
        secret_name = data.azurerm_key_vault_secret.example_secret.name
      }
    }
    min_replicas = 1
    max_replicas = 2
  }
  depends_on = [
    azurerm_user_assigned_identity.containerapp
  ]
  ingress {
      external_enabled = true
      target_port = 5000
      traffic_weight {
        percentage = 100
        latest_revision = true
      }
  }
}

output "container_app_url" {
  value       = azurerm_container_app.ca.ingress[0].fqdn
  description = "The URL of the Azure Container App"
}