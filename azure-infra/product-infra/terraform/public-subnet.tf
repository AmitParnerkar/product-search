/* Public Subnet */
resource "azurerm_subnet" "public" {
  name                 = "${var.network}-public-subnet"
  resource_group_name  = "spinach-tfstate"
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = [var.public_subnet_cidr]
}

/* Route Table for Public Subnet */
resource "azurerm_route_table" "public" {
  name                = "${var.network}-public-route"
  resource_group_name = "spinach-tfstate"
  location            = var.region

  route {
    name                    = "default-route"
    address_prefix = "0.0.0.0/0"  # Represents all outbound traffic
    next_hop_type            = "Internet"
  }

  tags = {
    Name = "${var.network}-public-route"
  }
}

/* Associate the Route Table to the Public Subnet */
resource "azurerm_subnet_route_table_association" "public" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.public.id
}
