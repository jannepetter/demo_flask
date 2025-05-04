terraform {
  backend "azurerm" {
    resource_group_name  = "common"
    storage_account_name = "tfbackenddemoflask"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.27.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "=2.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=3.3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.SUBSCRIPTION_ID
}

provider "azapi" {
}

provider "azuread" {
}