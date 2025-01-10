output "network" {
  value = azurerm_virtual_network.default.name
}

output "natIP" {
  value = azurerm_public_ip.nat.ip_address
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "security_web_id" {
  value = azurerm_network_security_group.web.id
}

output "common_security_group_id" {
  value = azurerm_network_security_group.common.id
}
