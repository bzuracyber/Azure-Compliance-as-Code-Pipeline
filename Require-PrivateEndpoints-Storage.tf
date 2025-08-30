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

resource "azurerm_policy_definition" "require_private_endpoints_storage" {
  name         = "require-private-endpoints-storage"
  display_name = "Storage accounts must use private endpoints"
  policy_type  = "Custom"
  mode         = "Indexed"

  policy_rule = jsonencode({
    "if": {
      "allOf": [
        { "field": "type", "equals": "Microsoft.Storage/storageAccounts" },
        { "field": "Microsoft.Storage/storageAccounts/privateEndpointConnections[*]", "exists": "false" }
      ]
    },
    "then": { "effect": "deny" }
  })
}

resource "azurerm_policy_assignment" "require_pe_assign" {
  name                 = "require-pe-assign"
  scope                = var.assignment_scope
  policy_definition_id = azurerm_policy_definition.require_private_endpoints_storage.id
  enforce              = true
}
