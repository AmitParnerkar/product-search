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

output "combined_sg_id" {
  value = azurerm_network_security_group.combined.id
}