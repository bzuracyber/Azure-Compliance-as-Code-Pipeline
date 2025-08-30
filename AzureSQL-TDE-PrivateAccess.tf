terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" { features {} }

variable "resource_group_name" { type = string }
variable "location"            { type = string }

# These are demo values; in real use, pass secrets via variables/Key Vault
variable "sql_admin_login" {
  type    = string
  default = "sqladminuser"
}
variable "sql_admin_password" {
  type    = string
  default = "ChangeM3!"
  sensitive = true
}

resource "azurerm_mssql_server" "sql" {
  name                         = "sql-sec-${substr(replace(var.resource_group_name, "/[\\W_]+/", ""), 0, 10)}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "db" {
  name      = "appdb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"

  # TDE is enabled by default in Azure SQL; set explicitly for clarity
  transparent_data_encryption_enabled = true
}

resource "azurerm_mssql_server_security_alert_policy" "alerts" {
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.sql.name
  state               = "Enabled"
}

check "sql_secure" {
  assert {
    condition     = azurerm_mssql_server.sql.public_network_access_enabled == false && azurerm_mssql_database.db.transparent_data_encryption_enabled
    error_message = "Azure SQL must have public networking disabled and TDE enabled."
  }
}
