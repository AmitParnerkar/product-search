resource "azurerm_resource_group" "main" {
  name     = "spinach-tfstate"
  location = var.location
}

# Create an Azure Storage account
resource "azurerm_storage_account" "terraform_state" {
  name                     = "spinachstate"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

# Create a container in the Storage account for Terraform state files
resource "azurerm_storage_container" "terraform_state" {
  name                  = "tfstate"
  container_access_type = "private"
  storage_account_name = azurerm_storage_account.terraform_state.name
}

# Create a table in the Storage account for state locking
resource "azurerm_storage_table" "terraform_state_lock" {
  name                 = "appstate"
  storage_account_name = azurerm_storage_account.terraform_state.name
}