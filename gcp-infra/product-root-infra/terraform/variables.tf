variable "credentials_file" {
  description = "Path to the GCP service account key file"
  default     = "~/.gcp/product-search-key.json"
}

variable "project_id" {
  description = "The GCP project ID"
}

variable "region" {
  description = "The GCP region"
  default     = "us-west1"
}
