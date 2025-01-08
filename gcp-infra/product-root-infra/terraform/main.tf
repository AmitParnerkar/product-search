/* Setup our Google provider */
provider "google" {
  credentials = file(var.gcp_credentials)  # Path to your service account key JSON file
  project     = var.project_id              # Your GCP project ID
  region      = var.region                  # The GCP region (e.g., "us-west1")
}
