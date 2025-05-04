variable "SUBSCRIPTION_ID" {
  type      = string
  sensitive = true
}

variable "location" {
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