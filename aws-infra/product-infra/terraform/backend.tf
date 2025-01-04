terraform {
  backend "s3" {
    bucket = "spinach-tfstate"
    key = "app-state"
    region = var.region
  }
}