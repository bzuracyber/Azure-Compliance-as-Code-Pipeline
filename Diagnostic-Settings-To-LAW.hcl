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

# Supply the resource IDs you want to attach diagnostics to (e.g., Storage Account IDs)
variable "target_resource_ids" {
  type        = list(string)
  description = "List of Azure resource IDs to attach diagnostic settings to"
  default     = []
}

resource "random_id" "law_suffix" {
  byte_length = 3
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-sec-${random_id.law_suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Attach diagnostic settings to each target resource
resource "azurerm_monitor_diagnostic_setting" "diag" {
  for_each                   = toset(var.target_resource_ids)
  name                       = "diag-to-law"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Common categories for Storage; for other resource types, adjust categories
  dynamic "enabled_log" {
    for_each = ["StorageRead", "StorageWrite", "StorageDelete"]
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
