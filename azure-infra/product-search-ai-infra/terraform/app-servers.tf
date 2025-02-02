/* Setup Azure provider */
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id  # Replace with your actual Azure Subscription ID
  client_id       = var.client_id        # Your Azure service principal client ID
  client_secret   = var.client_secret    # Your Azure service principal client secret
  tenant_id       = var.tenant_id       # Your Azure tenant ID
}

/* App servers (Azure VM scale set) */
resource "azurerm_linux_virtual_machine" "app" {
  count               = 2
  name                = "automated-app-${count.index}"
  resource_group_name = "spinach-tfstate"  # Replace with your Azure resource group
  location            = var.region
  size                = "Standard_D2s_v3"  # Replace with your desired VM size
  network_interface_ids = [azurerm_network_interface.app[count.index].id,]

  admin_username = "ubuntu"
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_ed25519.pub")  # Replace with your SSH key
  }

  os_disk {
    name              = "automated-app-${count.index}-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = 30  # Increase root disk size to 30 GB
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name = "automated-app-${count.index}"
  }
#
#   provisioner "remote-exec" {
#     connection {
#       host        = self.private_ip_address # Azure-specific IP references
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file("~/.ssh/id_ed25519")
#     }
#
#     inline = [
#       # Update and install prerequisites
#       "sudo apt-get update",
#       "sudo apt-get install -y ca-certificates curl gnupg",
#
#       # Set up Docker's official GPG key
#       "sudo install -m 0755 -d /etc/apt/keyrings",
#       "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
#       "sudo chmod a+r /etc/apt/keyrings/docker.asc",
#
#       # Add Docker repository
#       "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu jammy stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
#       "sudo apt-get update",
#
#       # Install Docker and related tools
#       "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
#
#       # Add user to the Docker group
#       "sudo usermod -aG docker ubuntu",
#
#       # Install additional tools
#       "sudo apt-get -y install vim",
#
#       # Download Docker Compose YAML file
#       "sudo wget -O /home/ubuntu/docker-compose.yaml https://gist.githubusercontent.com/AmitParnerkar/7d9305369284000be0b34951c634ef12/raw/f37ac57d1a9ba686b9660fe38ef79fcd45ca9603/docker-compose.yaml",
#
#       # Run Docker Compose
#       "cd /home/ubuntu",
#       "sudo docker compose up -d"
#     ]
#   }
}

/* Network Interface for App VMs */
resource "azurerm_network_interface" "app" {
  count               = 2
  name                = "automated-app-nic-${count.index}"
  location            = var.region
  resource_group_name = "spinach-tfstate"  # Replace with your Azure resource group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

/* Load Balancer */
resource "azurerm_lb" "app" {
  name                = "automated-vpc-lb"
  resource_group_name = "spinach-tfstate"  # Replace with your Azure resource group
  location            = var.region

  frontend_ip_configuration {
    name                 = azurerm_public_ip.public_lb_ip.name
    public_ip_address_id = azurerm_public_ip.public_lb_ip.id
  }
}

resource "azurerm_public_ip" "public_lb_ip" {
  name                = "PublicIPForLB"
  location            = var.region
  resource_group_name = "spinach-tfstate"
  allocation_method   = "Static"
}
#
# resource "azurerm_network_security_group" "web" {
#   name                = "automated-app-sg-web"
#   location            = var.region
#   resource_group_name = "spinach-tfstate" # Replace with your Azure resource group
#
#   # Allow HTTP traffic for web services
#   security_rule {
#     name                       = "AllowHTTP"
#     priority                   = 300
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#     source_port_range          = "80"
#     destination_port_range     = "80"
#   }
#
#   # Allow HTTPS traffic for secure web services
#   security_rule {
#     name                       = "AllowHTTPS"
#     priority                   = 400
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#     source_port_range          = "443"
#     destination_port_range     = "443"
#   }
#
#   # Allow all outbound traffic
#   security_rule {
#     name                       = "AllowAllOutbound"
#     priority                   = 1000
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#   }
# }


/* Network Security Group Association */
resource "azurerm_network_interface_security_group_association" "app" {
  count               = 2
  network_interface_id     = azurerm_network_interface.app[count.index].id
  network_security_group_id = data.terraform_remote_state.network.outputs.combined_sg_id
}
