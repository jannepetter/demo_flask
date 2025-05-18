variable "container_app_fqdn" {
  description = "The FQDN of the container app"
  type        = string
}

variable "resource_group" {
  type = object({
    location = string
    name     = string
  })
}