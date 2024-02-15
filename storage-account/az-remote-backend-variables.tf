# Company
variable "company" {
  type = string
  description = "This variable defines the name of the company"
  default = "CloudArchitecture"
}
# Environment
variable "environment" {
  type = string
  description = "This variable defines the environment to be built"
  default= "Test"
}
# Azure region
variable "location" {
  type = string
  description = "Azure region where resources will be created"
  default = "West Europe"
}