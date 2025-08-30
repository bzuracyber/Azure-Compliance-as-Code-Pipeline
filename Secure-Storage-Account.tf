terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" { features {} }

variable "resource_group_name" { type = string }
variable "location"            { type = string }

resource "random_id" "suffix" {
  byte_length = 3
}

resource "azurerm_storage_account" "secure" {
  name                             = "secst${random_id.suffix.hex}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"

  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
}

check "sa_https_tls12" {
  assert {
    condition     = azurerm_storage_account.secure.enable_https_traffic_only && azurerm_storage_account.secure.min_tls_version == "TLS1_2"
    error_message = "Storage accounts must enforce HTTPS and TLS >= 1.2."
  }
}
