terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.60"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
  }
}

locals {
  storage_account_prefix = "boot"
}

data "azurerm_client_config" "current" {
}

# Generate randon name for virtual machine
resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  number  = false
}

module "storage_account" {
  source                      = "./modules/storage_account"
  name                        = "${local.storage_account_prefix}${random_string.storage_account_suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  account_kind                = var.storage_account_kind
  account_tier                = var.storage_account_tier
  replication_type            = var.storage_account_replication_type
}

data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name
}

module "virtual_machine" {
  source                              = "./modules/virtual_machine"
  name                                = var.vm_name
  size                                = var.vm_size
  location                            = var.location
  public_ip                           = var.vm_public_ip
  vm_user                             = var.admin_username
  admin_ssh_public_key                = var.ssh_public_key
  os_disk_image                       = var.vm_os_disk_image
  resource_group_name                 = var.resource_group_name
  subnet_id                           = data.azurerm_subnet.subnet.id
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
  log_analytics_workspace_id          = data.azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id
  log_analytics_workspace_key         = data.azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key
  log_analytics_workspace_resource_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_retention_days        = var.log_analytics_retention_days
  script_storage_account_name         = var.script_storage_account_name
  script_storage_account_key          = var.script_storage_account_key
  container_name                      = var.container_name
  script_name                         = var.script_name
  azure_devops_url                    = var.azure_devops_url
  azure_devops_pat                    = var.azure_devops_pat
  azure_devops_agent_pool_name        = var.azure_devops_agent_pool_name
}