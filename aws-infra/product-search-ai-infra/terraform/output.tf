
output "appservers" {
  value = join(",", aws_instance.app.*.private_ip)
}

output "elbHostname" {
  value = aws_elb.app.dns_name
}

output "Hostname" {
  value = cloudflare_record.elb_record.name
}