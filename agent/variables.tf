variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "BaboAksWorkspace"
  type        = string
}

variable "log_analytics_resource_group_name" {
  description = "Specifies the name of the log analytics resource group"
  default     = "BaboAksWorkspace"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 30
}

variable "subnet_name" {
  description = "Specifies the name of the subnet where that will host the self-hosted agent virtual machine."
  type        = string
}

variable "virtual_network_name" {
  description = "Specifies the name of the virtual network that will host the self-hosted agent virtual machine."
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "Specifies the name of the resource group that contains the virtual network that will host the self-hosted agent virtual machine."
  type        = string
}

variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  default     = "westeurope"
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  default     = "BaboRG"
  type        = string
}

variable "vm_name" {
  description = "Specifies the name of the self-hosted agent virtual machine"
  default     = "TestVm"
  type        = string
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = false
}

variable "vm_size" {
  description = "Specifies the size of the self-hosted agent virtual machine"
  default     = "Standard_DS1_v2"
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the self-hosted agent virtual machine"
  default     = "Premium_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
  }
}

variable "admin_username" {
  description = "(Required) Specifies the admin username of the self-hosted agent virtual machine and AKS worker nodes."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the self-hosted agent virtual machine and AKS worker nodes."
  type        = string
}
variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

   validation {
    condition = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}


variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

   validation {
    condition = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "script_storage_account_name" {
  description = "(Required) Specifies the name of the storage account that contains the custom script."
  type        = string
}

variable "script_storage_account_key" {
  description = "(Required) Specifies the name of the storage account that contains the custom script."
  type        = string
}

variable "container_name" {
  description = "(Required) Specifies the name of the container that contains the custom script."
  type        = string
  default     = "scripts"
}

variable "script_name" {
  description = "(Required) Specifies the name of the custom script."
  type        = string
  default     = "configure-self-hosted-agent.sh"
}

variable "azure_devops_url" {
  description = "(Required) Specifies the URL of the target Azure DevOps organization."
  type        = string
}

variable "azure_devops_pat" {
  description = "(Required) Specifies the personal access token of the target Azure DevOps organization."
  type        = string
}

variable "azure_devops_agent_pool_name" {
  description = "(Required) Specifies the name of the agent pool in the Azure DevOps organization."
  type        = string
}