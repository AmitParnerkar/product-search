
output "appservers" {
  value = join(",", azurerm_linux_virtual_machine.app.*.private_ip_address)
}

output "elbHostname" {
  value = azurerm_public_ip.public_lb_ip.ip_address
}

output "Hostname" {
  value = cloudflare_record.elb_record.name
}