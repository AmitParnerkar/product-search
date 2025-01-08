/* Public subnet */
resource "google_compute_subnetwork" "public" {
  name          = "${var.network}-public-subnet-${var.region}"
  region        = var.region
  network       = google_compute_network.default.self_link

  ip_cidr_range = var.public_subnet_cidr
  private_ip_google_access = true

  depends_on = [google_compute_router.default]
}