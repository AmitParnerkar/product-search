# Azure variables
variable "client_id" {
  description = "Azure Client ID (App ID)"
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Client Secret (App Secret)"
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  sensitive   = true
}

variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  default     = "spinach-tfstate-rg"
}
