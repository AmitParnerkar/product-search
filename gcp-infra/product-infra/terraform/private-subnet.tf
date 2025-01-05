/* Private subnet */
resource "google_compute_subnetwork" "private" {
  name          = "my-private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.default.id
  private_ip_google_access = false
}

/* Private route for the subnet */
resource "google_compute_route" "private" {
  name       = "private-default-route"
  network    = google_compute_network.default.id
  dest_range = "0.0.0.0/0"  # Default route for private subnet
  next_hop_instance = google_compute_instance.nat.self_link  # Route traffic to NAT instance
  depends_on = [google_compute_subnetwork.private]
}

