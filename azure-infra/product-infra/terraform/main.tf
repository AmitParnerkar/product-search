/* Setup Azure provider */
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id  # Replace with your actual Azure Subscription ID
  client_id       = var.client_id        # Your Azure service principal client ID
  client_secret   = var.client_secret    # Your Azure service principal client secret
  tenant_id       = var.tenant_id       # Your Azure tenant ID
}

/* Define our Azure Virtual Network (VPC equivalent) */
resource "azurerm_virtual_network" "default" {
  name                = var.network
  location            = var.region
  resource_group_name = "spinach-tfstate"
  address_space       = [var.vpc_cidr]

  tags = {
    Name = var.network
  }
}

resource "azurerm_network_security_group" "combined" {
  name                = "${var.network}-combined-nsg"
  location            = var.region
  resource_group_name = "spinach-tfstate"

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVPN"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "1194"
    destination_port_range     = "1194"
  }

  security_rule {
    name                       = "AllowNatTraffic"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternalCommunication"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork" # Allows communication within the same VNet
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "0.0.0.0/0"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
}
