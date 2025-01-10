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

/* Common Network Security Group */
resource "azurerm_network_security_group" "common" {
  name                = "${var.network}-SG-common"
  location            = var.region
  resource_group_name = "spinach-tfstate"
  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }

  tags = {
    Name = "${var.network}-SG-common"
  }
}

resource "azurerm_network_security_group" "combined" {
  name                = "${var.network}-combined-nsg"
  location            = var.region
  resource_group_name = "spinach-tfstate"

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
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
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
}

/* Network Security Group for Web Server */
resource "azurerm_network_security_group" "web" {
  name                = "${var.network}-SG-web"
  location            = var.region
  resource_group_name = "spinach-tfstate"

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "80"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "443"
    destination_port_range     = "443"
  }

  tags = {
    Name = "${var.network}-SG-web"
  }
}
