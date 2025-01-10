terraform {
  backend "azurerm" {
    resource_group_name  = "spinach-tfstate"
    storage_account_name = "spinachstate"
    container_name       = "tfstate"
    key                  = "appstate"
  }
}
