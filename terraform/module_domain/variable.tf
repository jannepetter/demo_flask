variable "app_name" {
  type      = string
  sensitive = false
}

variable "environment" {
  type      = string
  sensitive = false
}

variable "custom_domain" {
  type      = string
  sensitive = false
}

variable "common_resources_rg_name" {
  type      = string
  sensitive = false
}

variable "cert_name" {
  type      = string
  sensitive = false
}

variable "ca_env_name" {
  type      = string
  sensitive = false
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  sensitive = true
}