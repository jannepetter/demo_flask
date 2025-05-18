
variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "demoflask"
}

variable "environments" {
  description = "List of environment configurations with all required values"
  type = list(object({
    environment  = string
    location     = string
    cpu          = number
    memory       = string
    min_replicas = number
    max_replicas = number
  }))
  default = [
    {
      environment  = "testing"
      location     = "northeurope"
      cpu          = 0.25
      memory       = "0.5Gi"
      min_replicas = 1
      max_replicas = 2
    }
  ]
}
module "infra" {
  for_each        = { for env in var.environments : env.environment => env }
  source          = "../module_infra"
  SUBSCRIPTION_ID = var.SUBSCRIPTION_ID
  location        = each.value.location
  app_name        = var.app_name
  environment     = each.value.environment
}

module "app" {
  for_each             = { for env in var.environments : env.environment => env }
  source               = "../module_app"
  acr_id               = module.infra[each.key].acr.id
  acr_login_server     = module.infra[each.key].acr.login_server
  resource_group       = module.infra[each.key].resource_group
  example_secret_name  = module.infra[each.key].example_secret.name
  example_secret_value = module.infra[each.key].example_secret.value
  tenant_id            = module.infra[each.key].subscription.tenant_id
  app_name             = var.app_name
  environment          = each.value.environment
  cpu                  = each.value.cpu
  memory               = each.value.memory
  min_replicas         = each.value.min_replicas
  max_replicas         = each.value.max_replicas
  depends_on           = [module.infra]
}

module "dns" {
  for_each          = { for env in var.environments : env.environment => env }
  source            = "../module_dns"
  resource_group    = module.infra[each.key].common_resource_group
  container_app_url = module.app[each.key].container_app_url
  depends_on        = [module.infra, module.app]
}

output "app_urls" {
  value = {
    for env_key, app in module.app :
    env_key => app.container_app_url
  }
}