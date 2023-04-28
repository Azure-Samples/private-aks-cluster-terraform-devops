terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.50.0"
    }
  }

  required_version = ">= 0.14.9"
}

resource "azurerm_virtual_network_peering" "peering" {
  name                      = var.peering_name_1_to_2
  resource_group_name       = var.vnet_1_rg
  virtual_network_name      = var.vnet_1_name
  remote_virtual_network_id = var.vnet_2_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peering-back" {
  name                      = var.peering_name_2_to_1
  resource_group_name       = var.vnet_2_rg
  virtual_network_name      = var.vnet_2_name
  remote_virtual_network_id = var.vnet_1_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}