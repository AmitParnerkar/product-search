/* Private subnet */
resource "google_compute_subnetwork" "private" {
  name          = "${var.network}-private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.default.name
  private_ip_google_access = false
}
