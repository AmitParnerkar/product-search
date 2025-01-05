# Configure Cloudflare provider
provider "cloudflare" {
  api_key = var.api_key
  email    = "amit.parnerkar@gmail.com"
}

# Data source to retrieve Cloudflare zone ID
data "cloudflare_zone" "main_zone" {
  name = "spinachsoftware.com"
}

resource "cloudflare_record" "elb_record" {
  zone_id  = data.cloudflare_zone.main_zone.id
  name     = "bby-ai-gcp.spinachsoftware.com"
  type     = "A"  # Use A record instead of CNAME
  content  = google_compute_address.lb_ip.address  # This should be a valid IP address from Google Cloud
  proxied  = true
}

# resource "cloudflare_record" "elb_record" {
#   zone_id  = data.cloudflare_zone.main_zone.id
#   name     = "bby-ai-gcp.spinachsoftware.com"
#   type     = "CNAME"
#   content  = google_compute_address.lb_ip.address  # This should be a valid external IP address
#   proxied  = true
# }
