variable "name" {
  description = "(Required) Specifies the name of the network security group"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the network security group"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the network security group"
  type        = string
}

variable "security_rules" {
  description = "(Optional) Specifies the security rules of the network security group"
  type        = list(object)
  default     = []
}

variable "tags" {
  description = "(Optional) Specifies the tags of the network security group"
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace resource id"
  type        = string
}
