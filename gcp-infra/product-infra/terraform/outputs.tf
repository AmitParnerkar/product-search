output "nat_ip" {
  value = google_compute_address.nat_ip.address
}

output "private_subnet_name" {
  value = google_compute_subnetwork.private.name
}

output "public_subnet_name" {
  value = google_compute_subnetwork.public.name
}

output "network" {
  value = google_compute_network.default.name
}

output "security_web_http" {
  value = google_compute_firewall.web_http.name
}

output "security_web_https" {
  value = google_compute_firewall.web_https.name
}

output "common_security_group_egress" {
  value = google_compute_firewall.common_egress.name
}

output "common_security_group_ingress" {
  value = google_compute_firewall.common_ingress.name
}

# output "deployer_key_name" {
#   value = google_compute_ssh_key.deployer.public_key
# }
