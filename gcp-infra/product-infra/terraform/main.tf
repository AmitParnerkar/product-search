# Setup our Google provider
provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.project_id
  region      = var.region
}

# Create VPC network
resource "google_compute_network" "default" {
  name                    = var.network
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Common firewall rule
# Firewall rule for common ingress traffic (within VPC)
resource "google_compute_firewall" "common_ingress" {
  name    = "${var.network}-common-ingress"
  network = google_compute_network.default.name

  # Allow all inbound traffic within the VPC
  allow {
    protocol = "all"
  }

  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8"] # Replace with your VPC CIDR range

  # Optional: Apply to all instances or specific target tags
  target_tags = ["${var.network}-common-ingress"]
}

# Firewall rule for common egress traffic (to the internet)
resource "google_compute_firewall" "common_egress" {
  name    = "${var.network}-common-egress"
  network = google_compute_network.default.name

  # Allow all outbound traffic
  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]

  # Optional: Apply to all instances or specific target tags
  target_tags = ["${var.network}-common-egress"]
}

# Internet gateway (default route)
resource "google_compute_router" "default" {
  name    = "${var.network}-router"
  region  = var.region
  network = google_compute_network.default.name
}

resource "google_compute_router_nat" "default" {
  name                               = "${var.network}-nat"
  router                             = google_compute_router.default.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall rule to allow SSH and VPN traffic
# Ingress rule for SSH traffic
resource "google_compute_firewall" "nat_ssh" {
  name    = "${var.network}-nat-ssh"
  network = google_compute_network.default.name

  description = "Allow SSH traffic from the internet"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["${var.network}-nat-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

# Ingress rule for VPN traffic (UDP 1194)
resource "google_compute_firewall" "nat_vpn" {
  name    = "${var.network}-nat-vpn"
  network = google_compute_network.default.name
  description = "Allow VPN traffic (UDP 1194) from the internet"

  direction     = "INGRESS"
  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network}-nat-vpn"]
}

# Egress rule for unrestricted outbound traffic
resource "google_compute_firewall" "nat_egress" {
  name    = "${var.network}-nat-egress"
  network = google_compute_network.default.name
  description = "Allow all outbound traffic"

  direction     = "EGRESS"
  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["${var.network}-nat-egress"]
}

# Security group for web servers
# Ingress rule for HTTP traffic
resource "google_compute_firewall" "web_http" {
  name    = "${var.network}-web-http"
  network = google_compute_network.default.name
  description = "Allow HTTP traffic from the internet"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["${var.network}-web-http"]
  source_ranges = ["0.0.0.0/0"]
}

# Ingress rule for HTTPS traffic
resource "google_compute_firewall" "web_https" {
  name    = "${var.network}-web-https"
  network = google_compute_network.default.name
  description = "Allow HTTPS traffic from the internet"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["${var.network}-web-https"]
  source_ranges = ["0.0.0.0/0"]
}
