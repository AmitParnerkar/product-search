# Google Cloud provider configuration variables
variable "gcp_credentials" {
  description = "Path to the GCP credentials JSON file"
  sensitive   = true
}

variable "network" {
  description = "vpc name"
  default = "automated-vpc"
}

variable "project_id" {
  description = "GCP project ID"
}

variable "region" {
  description = "GCP region"
  default     = "us-west1"
}

variable "zone" {
  description = "GCP zone"
  default     = "us-west1-a"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/8"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.0.1.0/24"
}

# GCP equivalent for instance base images (Ubuntu 22.04)
variable "images" {
  description = "Base images to launch instances"
  default = {
    us-central1 = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230929"
    us-east1    = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230929"
    us-west1    = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230929"
    europe-west1 = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230929"
    asia-east1   = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230929"
  }
}
