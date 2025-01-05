# Setup our Google provider
provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# Create VPC network
resource "google_compute_network" "default" {
  name                    = "automated-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Common firewall rule
resource "google_compute_firewall" "common" {
  name    = "fw-common-automated-vpc"
  network = google_compute_network.default.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]

  direction = "INGRESS"

  target_tags = ["common"]
}

# Internet gateway (default route)
resource "google_compute_router" "default" {
  name    = "automated-vpc-router"
  region  = var.region
  network = google_compute_network.default.id
}

resource "google_compute_router_nat" "default" {
  name                               = "automated-vpc-nat"
  router                             = google_compute_router.default.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Security group for NAT server (using tags and firewall rules)
resource "google_compute_firewall" "nat" {
  name    = "fw-nat-automated-vpc"
  network = google_compute_network.default.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["nat"]
}

# Security group for web servers
resource "google_compute_firewall" "web" {
  name    = "fw-web-automated-vpc"
  network = google_compute_network.default.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]
}


