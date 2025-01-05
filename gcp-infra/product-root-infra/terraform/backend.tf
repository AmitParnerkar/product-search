/* Create a GCS bucket for Terraform state */
resource "google_storage_bucket" "terraform_state" {
  name                        = "spinach-tfstate"
  location                    = var.region
  force_destroy               = false
  versioning {
    enabled = true
  }
}

/* (Optional) Configure lifecycle rules for state management */
resource "google_storage_bucket_iam_binding" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"

  members = [
    "serviceAccount:1035107826094-compute@developer.gserviceaccount.com"
  ]
}

/* Locking is natively supported in GCS and does not require an additional resource like DynamoDB */
