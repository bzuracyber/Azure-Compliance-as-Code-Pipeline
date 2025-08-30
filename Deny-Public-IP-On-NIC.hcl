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

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip-on-nic"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Deny public IP on NICs"

  policy_rule = jsonencode({
    "if": {
      "allOf": [
        { "field": "type", "equals": "Microsoft.Network/networkInterfaces" },
        { "field": "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id", "exists": "true" }
      ]
    },
    "then": { "effect": "deny" }
  })
}

resource "azurerm_policy_assignment" "deny_public_ip_assign" {
  name                 = "deny-public-ip-assign"
  scope                = var.assignment_scope
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  enforce              = true
}
