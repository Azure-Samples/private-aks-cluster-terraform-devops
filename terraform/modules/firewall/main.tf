terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  threat_intel_mode   = var.threat_intel_mode
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  tags                = var.tags


  ip_configuration {
    name                 = "fw_ip_config"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  lifecycle {
    ignore_changes = [
      tags,
      
    ]
  }
}

resource "azurerm_firewall_policy" "policy" {
  name                = "${var.name}Policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "policy" {
  name               = "AksEgressPolicyRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 500

  application_rule_collection {
    name     = "ApplicationRules"
    priority = 500
    action   = "Allow"

    rule {
      name             = "AllowMicrosoftFqdns"
      source_addresses = ["*"]

      destination_fqdns = [
        "*.cdn.mscr.io",
        "mcr.microsoft.com",
        "*.data.mcr.microsoft.com",
        "management.azure.com",
        "login.microsoftonline.com",
        "acs-mirror.azureedge.net",
        "dc.services.visualstudio.com",
        "*.opinsights.azure.com",
        "*.oms.opinsights.azure.com",
        "*.microsoftonline.com",
        "*.monitoring.azure.com",
      ]

      protocols {
        port = "80"
        type = "Http"
      }

      protocols {
        port = "443"
        type = "Https"
      }
    }

    rule {
      name             = "AllowFqdnsForOsUpdates"
      source_addresses = ["*"]

      destination_fqdns = [
        "download.opensuse.org",
        "security.ubuntu.com",
        "ntp.ubuntu.com",
        "packages.microsoft.com",
        "snapcraft.io"
      ]

      protocols {
        port = "80"
        type = "Http"
      }

      protocols {
        port = "443"
        type = "Https"
      }
    }
    
    rule {
      name             = "AllowImagesFqdns"
      source_addresses = ["*"]

      destination_fqdns = [
        "auth.docker.io",
        "registry-1.docker.io",
        "production.cloudflare.docker.com"
      ]

      protocols {
        port = "80"
        type = "Http"
      }

      protocols {
        port = "443"
        type = "Https"
      }
    }

    rule {
      name             = "AllowBing"
      source_addresses = ["*"]

      destination_fqdns = [
        "*.bing.com"
      ]

      protocols {
        port = "80"
        type = "Http"
      }

      protocols {
        port = "443"
        type = "Https"
      }
    }

    rule {
      name             = "AllowGoogle"
      source_addresses = ["*"]

      destination_fqdns = [
        "*.google.com"
      ]

      protocols {
        port = "80"
        type = "Http"
      }

      protocols {
        port = "443"
        type = "Https"
      }
    }
  }

  network_rule_collection {
    name     = "NetworkRules"
    priority = 400
    action   = "Allow"

    rule {
      name                  = "Time"
      source_addresses      = ["*"]
      destination_ports     = ["123"]
      destination_addresses = ["*"]
      protocols             = ["UDP"]
    }

    rule {
      name                  = "DNS"
      source_addresses      = ["*"]
      destination_ports     = ["53"]
      destination_addresses = ["*"]
      protocols             = ["UDP"]
    }

    rule {
      name                  = "ServiceTags"
      source_addresses      = ["*"]
      destination_ports     = ["*"]
      destination_addresses = [
        "AzureContainerRegistry",
        "MicrosoftContainerRegistry",
        "AzureActiveDirectory"
      ]
      protocols             = ["Any"]
    }

    rule {
      name                  = "Internet"
      source_addresses      = ["*"]
      destination_ports     = ["*"]
      destination_addresses = ["*"]
      protocols             = ["TCP"]
    }
  }

  lifecycle {
    ignore_changes = [
      application_rule_collection,
      network_rule_collection,
      nat_rule_collection
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "pip_settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_public_ip.pip.id
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
