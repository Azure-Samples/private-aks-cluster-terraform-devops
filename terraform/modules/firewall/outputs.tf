output "private_ip_address" {
  description = "Specifies the private IP address of the firewall."
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}