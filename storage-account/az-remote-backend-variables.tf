# Company
variable "company" {
  type = string
  description = "This variable defines the name of the company"
}
# Environment
variable "environment" {
  type = string
  description = "This variable defines the environment to be built"
}
# Azure region
variable "location" {
  type = string
  description = "Azure region where resources will be created"
  default = "north europe"
}