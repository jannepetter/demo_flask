variable "resource_group" {
  type = object({
    location = string
    name     = string
  })
  sensitive = true
}

variable "container_app_url" {
  type      = string
  sensitive = false
}