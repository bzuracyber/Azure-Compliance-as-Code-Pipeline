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

# Provide specific admin IP ranges if you want to allow SSH (port 22)
variable "allowed_admin_cidrs" {
  type        = list(string)
  default     = []
  description = "Approved admin IP ranges for SSH allow rule"
}

resource "azurerm_network_security_group" "secure" {
  name                = "nsg-secure"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Deny RDP from Internet
  security_rule {
    name                       = "Deny-RDP-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Deny SSH from Internet by default
  security_rule {
    name                       = "Deny-SSH-Internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Optional: Allow SSH from approved admin CIDRs (if provided)
  dynamic "security_rule" {
    for_each = length(var.allowed_admin_cidrs) > 0 ? [1] : []
    content {
      name                       = "Allow-SSH-Admins"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefixes    = var.allowed_admin_cidrs
      destination_address_prefix = "*"
    }
  }

  lifecycle {
    precondition {
      condition     = !contains(var.allowed_admin_cidrs, "0.0.0.0/0")
      error_message = "SSH may not be open to the Internet. Provide specific admin CIDRs."
    }
  }
}
