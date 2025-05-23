variable "resource_group" {
  type = object({
    location = string
    name     = string
  })
  sensitive = true
}

variable "acr_id" {
  type      = string
  sensitive = true
}

variable "acr_login_server" {
  type      = string
  sensitive = true
}

variable "example_secret_name" {
  type      = string
  sensitive = true
}
variable "example_secret_value" {
  type      = string
  sensitive = true
}
variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "app_name" {
  type      = string
  sensitive = false
}

variable "environment" {
  type      = string
  sensitive = false
}

variable "cpu" {
  type      = number
  sensitive = false
}
variable "memory" {
  type      = string
  sensitive = false
}

variable "min_replicas" {
  type      = number
  sensitive = false
}

variable "max_replicas" {
  type      = number
  sensitive = false
}