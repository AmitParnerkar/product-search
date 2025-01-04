data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "spinach-tfstate"
    key    = "app-state"
    region = var.region
  }
}