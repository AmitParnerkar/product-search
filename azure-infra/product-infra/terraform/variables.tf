variable "subscription_id" {
  description = "Azure Subscription ID"
  sensitive   = true
}

variable "client_id" {
  description = "Azure Client ID (Service Principal)"
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Client Secret (Service Principal)"
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  sensitive   = true
}

variable "region" {
  description = "Azure region"
  default     = "East US"
}

variable "network" {
  description = "VPC name"
  default     = "automated-vpc"
}

variable "az" {
  description = "Azure availability_zone"
  default     = "1"  # Azure availability zones are typically numbered, like "1", "2", "3", etc.
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.128.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet in the Virtual Network"
  default     = "10.128.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet in the Virtual Network"
  default     = "10.128.1.0/24"
}

# Azure Images (UBUNTU, etc.) for various regions
variable "images" {
  description = "Base Image URIs for Azure VMs"
  default = {
    "East US"     = "Canonical:UbuntuServer:22.04-LTS:latest"
    "West US"     = "Canonical:UbuntuServer:22.04-LTS:latest"
    "East US 2"   = "Canonical:UbuntuServer:22.04-LTS:latest"
    "West US 2"   = "Canonical:UbuntuServer:22.04-LTS:latest"
    "Central US"  = "Canonical:UbuntuServer:22.04-LTS:latest"
    "North Europe"= "Canonical:UbuntuServer:22.04-LTS:latest"
    "West Europe" = "Canonical:UbuntuServer:22.04-LTS:latest"
    "Southeast Asia" = "Canonical:UbuntuServer:22.04-LTS:latest"
    "Australia East" = "Canonical:UbuntuServer:22.04-LTS:latest"
    "Japan East"     = "Canonical:UbuntuServer:22.04-LTS:latest"
  }
}
