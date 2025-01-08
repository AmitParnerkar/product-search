output "nat_ip" {
  value = google_compute_address.nat_ip.address
}

output "private_subnet_id" {
  value = google_compute_subnetwork.private.id
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public.id
}

output "security_web_http_id" {
  value = google_compute_firewall.web_http.name
}

output "security_web_https_id" {
  value = google_compute_firewall.web_https.name
}

output "common_security_group_id" {
  value = google_compute_firewall.common_egress.name
}

output "network_name" {
  value = google_compute_network.default.name
}

# output "deployer_key_name" {
#   value = google_compute_ssh_key.deployer.public_key
# }
