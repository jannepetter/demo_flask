
variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "demoflask"
}

variable "environments" {
  type = list(object({
    environment  = string
    location     = string
    cpu          = number
    memory       = string
    min_replicas = number
    max_replicas = number
  }))
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
}

output "app_urls" {
  value = {
    for env_key, app in module.app :
    env_key => app.container_app_url
  }
}