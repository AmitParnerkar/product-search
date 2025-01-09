# Output the private IPs of the app servers in GCP
# output "appservers" {
#   value = join(",", google_compute_instance.app.*.network_interface[0].network_ip)
# }

# Output the external IP of the GCP load balancer
output "elbHostname" {
  value = google_compute_global_address.lb_ip.address
}

# Output the Cloudflare record name for the load balancer
output "Hostname" {
  value = cloudflare_record.elb_record.name
}
