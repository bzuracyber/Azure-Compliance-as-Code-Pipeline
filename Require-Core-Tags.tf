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

resource "azurerm_policy_definition" "deny_missing_owner" {
  name         = "deny-missing-owner"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Deny: Missing tag 'Owner'"
  policy_rule  = jsonencode({
    "if": { "field": "tags['Owner']", "exists": "false" },
    "then": { "effect": "deny" }
  })
}

resource "azurerm_policy_definition" "deny_missing_env" {
  name         = "deny-missing-environment"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Deny: Missing tag 'Environment'"
  policy_rule  = jsonencode({
    "if": { "field": "tags['Environment']", "exists": "false" },
    "then": { "effect": "deny" }
  })
}

resource "azurerm_policy_set_definition" "tag_initiative" {
  name         = "require-core-tags"
  display_name = "Require core tags (Owner, Environment)"
  policy_type  = "Custom"
  policy_definitions = jsonencode([
    { "policyDefinitionId": azurerm_policy_definition.deny_missing_owner.id },
    { "policyDefinitionId": azurerm_policy_definition.deny_missing_env.id   }
  ])
}

resource "azurerm_policy_assignment" "tag_initiative_assign" {
  name                 = "assign-core-tags"
  scope                = var.assignment_scope
  policy_definition_id = azurerm_policy_set_definition.tag_initiative.id
  enforce              = true
}
