terraform {
  backend "gcs" {
    bucket = "spinach-tfstate"  # Replace with your GCP bucket name
    prefix = "app-state"       # Folder-like prefix for state files
  }
}