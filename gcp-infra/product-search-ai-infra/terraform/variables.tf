/* Cloudflare API key */
variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  sensitive   = true
}

variable "project_id" {
  description = "GCP project ID"
}

variable "gcp_credentials" {
  description = "Path to the GCP service account key file"
  sensitive   = true
}

/* GCP region */
variable "region" {
  description = "GCP region"
  default     = "us-west1"  # Example GCP region
}

/* GCP zone */
variable "az" {
  description = "GCP availability zone"
  default     = "us-west1-a"  # Example GCP availability zone
}

/* Image definitions for GCP (equivalent to AMIs in AWS) */
variable "images" {
  description = "Base image to launch the instances with"
  default = {
    "us-west1" = "ubuntu-2204-jammy-v20241218"  # Replace with the correct GCP image for your region
     # Add more regions as needed
  }
}
