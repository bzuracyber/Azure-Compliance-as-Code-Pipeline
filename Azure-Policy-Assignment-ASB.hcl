terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" { features {} }

variable "assignment_scope" {
  type        = string
  description = "Scope (subscription, management group, or resource group ID) for policy assignment"
}

# Use data source to fetch the built-in Azure Security Benchmark (ASB) initiative
data "azurerm_policy_set_definition" "asb" {
  display_name = "Azure Security Benchmark"
}

resource "azurerm_policy_assignment" "asb_assign" {
  name                 = "assign-asb"
  scope                = var.assignment_scope
  policy_definition_id = data.azurerm_policy_set_definition.asb.id
  enforce              = true
}
