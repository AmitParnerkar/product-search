/* Public subnet */
resource "google_compute_subnetwork" "public" {
  name          = "${var.network}-public-subnet-${var.region}"
  region        = var.region
  network       = google_compute_network.default.self_link

  ip_cidr_range = var.public_subnet_cidr
  private_ip_google_access = true

  depends_on = [google_compute_router.default]
}

/* Public route for the subnet */
resource "google_compute_route" "public" {
  name       = "${var.network}-dafult-internet-route"
  network    = google_compute_network.default.name
  dest_range = "0.0.0.0/0"  # Default route for public subnet

  next_hop_gateway = "default-internet-gateway"  # Route traffic to the internet gateway

  depends_on = [google_compute_subnetwork.public]
}