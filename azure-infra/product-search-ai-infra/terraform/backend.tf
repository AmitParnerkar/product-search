data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "spinach-tfstate"      # Replace with your Azure resource group
    storage_account_name = "spinachstate"        # Replace with your Azure Storage account name
    container_name       = "tfstate"             # Replace with your container name
    key                  = "appstate"           # Key to locate the specific state file
  }
}