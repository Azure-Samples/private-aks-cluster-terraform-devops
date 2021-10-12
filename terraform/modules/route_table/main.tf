terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_route_table" "rt" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  route {
    name                   = "kubenetfw_fw_r"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  lifecycle {
    ignore_changes = [
      tags,
      route
    ]
  }
}

resource "azurerm_subnet_route_table_association" "subnet_association" {
  for_each = var.subnets_to_associate

  subnet_id      = "/subscriptions/${each.value.subscription_id}/resourceGroups/${each.value.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${each.value.virtual_network_name}/subnets/${each.key}"
  route_table_id = azurerm_route_table.rt.id
}