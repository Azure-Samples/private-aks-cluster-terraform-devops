terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                           = var.name
  target_resource_id             = var.target_resource_id

  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id 

  storage_account_id             = var.storage_account_id

  dynamic "enabled_log" {
    for_each = toset(logs)
    content {
      category = each.key
    }
  }

  dynamic "metric" {
    for_each = toset(metrics)
    content {
      category = each.key
      enabled  = true
    }
  }
}
