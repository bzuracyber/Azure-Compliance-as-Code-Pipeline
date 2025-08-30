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

# Set to true to provision a private endpoint & private DNS for Key Vault
variable "enable_private_endpoint" {
  type    = bool
  default = true
}

data "azurerm_client_config" "current" {}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-sec-${random_id.suffix.hex}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = false
}

# Private endpoint plumbing (optional, controlled by var.enable_private_endpoint)
resource "azurerm_virtual_network" "pe_vnet" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "kv-pe-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "pe_subnet" {
  count                = var.enable_private_endpoint ? 1 : 0
  name                 = "kv-pe-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.pe_vnet[0].name
  address_prefixes     = ["10.10.1.0/24"]

  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_endpoint" "kv_pe" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.pe_subnet[0].id

  private_service_connection {
    name                           = "kv-priv-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_zone" "kv_privdns" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_privdns_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "kv-pe-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv_privdns[0].name
  virtual_network_id    = azurerm_virtual_network.pe_vnet[0].id
}

resource "azurerm_private_dns_a_record" "kv_privdns_record" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_key_vault.kv.name
  zone_name           = azurerm_private_dns_zone.kv_privdns[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.kv_pe[0].custom_dns_configs[0].ip_addresses[0]]
}

check "kv_purge_protect" {
  assert {
    condition     = azurerm_key_vault.kv.purge_protection_enabled
    error_message = "Key Vault must have purge protection enabled."
  }
}
