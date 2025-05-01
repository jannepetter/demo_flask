variable "rg_location" {
  type      = string
  sensitive = true
}

variable "rg_name" {
  type      = string
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