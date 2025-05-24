terraform {
  required_version = "~> 1.11.0"
  backend "azurerm" {
    subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias           = "acme"
  subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
}
