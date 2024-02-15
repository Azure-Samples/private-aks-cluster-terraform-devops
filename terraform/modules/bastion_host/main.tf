terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}PublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_bastion_host.bastion_host.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "pip_settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_public_ip.public_ip.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DDoSProtectionNotifications"
  }

  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }

  enabled_log {
    category = "DDoSMitigationReports"
  }

  metric {
    category = "AllMetrics"
  }
}
