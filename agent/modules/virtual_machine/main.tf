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
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.name)
  count               = var.public_ip ? 1 : 0
  tags                = var.tags

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}Nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}Nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.public_ip[0].id, "")
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_security_group.nsg]
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.nic.id]
  size                          = var.size
  computer_name                 = var.name
  admin_username                = var.vm_user
  tags                          = var.tags

  os_disk {
    name                 = "${var.name}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  admin_ssh_key {
    username   = var.vm_user
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    offer     = lookup(var.os_disk_image, "offer", null)
    publisher = lookup(var.os_disk_image, "publisher", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
  }

  lifecycle {
    ignore_changes = [
        tags
    ]
  }

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                    = "${var.name}CustomScript"
  virtual_machine_id      = azurerm_linux_virtual_machine.virtual_machine.id
  publisher               = "Microsoft.Azure.Extensions"
  type                    = "CustomScript"
  type_handler_version    = "2.0"

  settings = <<SETTINGS
    {
      "fileUris": ["https://${var.script_storage_account_name}.blob.core.windows.net/${var.container_name}/${var.script_name}"],
      "commandToExecute": "bash ${var.script_name} '${var.vm_user}' '${var.azure_devops_url}' '${var.azure_devops_pat}' '${var.azure_devops_agent_pool_name}'"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.script_storage_account_name}",
      "storageAccountKey": "${var.script_storage_account_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_virtual_machine_extension" "monitor_agent" {
  name                       = "${var.name}MonitoringAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.virtual_machine.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.12"
  auto_upgrade_minor_version = true
 
  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
  SETTINGS
 
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [azurerm_virtual_machine_extension.custom_script]
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  name                       = "${var.name}DependencyAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.virtual_machine.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
 
  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
  SETTINGS
 
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [azurerm_virtual_machine_extension.monitor_agent]
}

resource "azurerm_monitor_diagnostic_setting" "nsg_settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id

  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

 log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
}