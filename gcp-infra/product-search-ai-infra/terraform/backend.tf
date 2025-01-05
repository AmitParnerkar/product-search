data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = "spinach-tfstate"  # GCS bucket name where the state file is stored
    prefix = "app-state"        # Folder-like prefix for state files (e.g., 'network-state' or 'app-state')
  }
}
