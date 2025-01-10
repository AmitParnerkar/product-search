/* NAT Server VM */
resource "azurerm_linux_virtual_machine" "nat" {
  name                = "${var.network}-nat-server"
  resource_group_name = "spinach-tfstate"
  location            = var.region
  size                = "Standard_B2s"
  admin_username      = "ubuntu"
  network_interface_ids = [azurerm_network_interface.nat.id]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    name              = "nat-server-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"  # Or "Premium_LRS" for better performance
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.nat.ip_address
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
    }

    inline = [
      "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "echo 1 | sudo tee /proc/sys/net/ipv4/conf/all/forwarding",
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu jammy stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo apt-get -y install vim",
      "sudo mkdir -p /etc/openvpn",
      "sudo docker run --name ovpn-data -v /etc/openvpn busybox",
      "sudo docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -p ${var.vpc_cidr} -u udp://${azurerm_public_ip.nat.ip_address}",
    ]
  }

  tags = {
    Name = "${var.network}-nat-server"
  }
}

/* Network Interface for NAT VM */
resource "azurerm_network_interface" "nat" {
  name                = "${var.network}-nat-server-nic"
  location            = var.region
  resource_group_name = "spinach-tfstate"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nat.id
  }

  tags = {
    Name = "${var.network}-nat-server-nic"
  }
}

/* Public IP for NAT VM */
resource "azurerm_public_ip" "nat" {
  name                         = "${var.network}-nat-server-ip"
  location                     = var.region
  resource_group_name          = "spinach-tfstate"
  allocation_method            = "Static"
  idle_timeout_in_minutes      = 4

  tags = {
    Name = "${var.network}-nat-server-ip"
  }
}

// Associate this NSG with the NIC:
resource "azurerm_network_interface_security_group_association" "combined" {
  network_interface_id      = azurerm_network_interface.nat.id
  network_security_group_id = azurerm_network_security_group.combined.id
}