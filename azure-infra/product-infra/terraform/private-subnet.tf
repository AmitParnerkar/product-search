/* Private Subnet */
resource "azurerm_subnet" "private" {
  name                 = "${var.network}-private-subnet"
  resource_group_name  = "spinach-tfstate"
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = [var.private_subnet_cidr]

}

/* Route Table for Private Subnet */
resource "azurerm_route_table" "private" {
  name                = "${var.network}-private-route"
  resource_group_name = "spinach-tfstate"
  location            = var.region

  route {
    name                     = "default-route"
    address_prefix           = "0.0.0.0/0" # Route all traffic
    next_hop_type            = "VirtualAppliance"
    next_hop_in_ip_address   = azurerm_public_ip.nat.ip_address  # Reference to the NAT Gateway Public IP
  }

  tags = {
    Name = "${var.network}-private-route"
  }
}


/* Associate the Route Table to the Private Subnet */
resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.private.id
}
