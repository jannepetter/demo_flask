provider "azurerm" {
  features {}
  subscription_id = var.SUBSCRIPTION_ID
}

provider "azapi" {
}

provider "azuread" {
}

module "infra" {
  source          = "../module_infra"
  SUBSCRIPTION_ID = var.SUBSCRIPTION_ID
}

module "app" {
  source               = "../module_app"
  acr_id               = module.infra.acr.id
  acr_login_server     = module.infra.acr.login_server
  rg_name              = module.infra.resource_group.name
  rg_location          = module.infra.resource_group.location
  example_secret_name  = module.infra.example_secret.name
  example_secret_value = module.infra.example_secret.value
  tenant_id            = module.infra.subscription.tenant_id
}

output "app_url" {
  value = module.app.container_app_url
}