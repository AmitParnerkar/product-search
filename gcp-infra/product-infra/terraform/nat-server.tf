# Declare the Google Compute Address resource to allocate a static IP
resource "google_compute_address" "nat_ip" {
  name   = "${var.network}-nat-ip"
  region = var.region
}

# Declare the Google Compute Instance resource (NAT instance)
resource "google_compute_instance" "nat" {
  name         = "${var.network}-nat"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20241218"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.name
    access_config {
      # Use the nat_ip from google_compute_address
      nat_ip = google_compute_address.nat_ip.address
    }
  }

  tags = ["${var.network}-common-egress",
    "${var.network}-common-ingress",
    "${var.network}-nat-ssh",
    "${var.network}-nat-vpn",
    "${var.network}-nat-egress"]

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  /* Define startup script for instance provisioning */
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Enable IP masquerading for NAT
    sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
    echo 1 | sudo tee /proc/sys/net/ipv4/conf/all/forwarding

    # Install Docker
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker ubuntu
    sudo apt-get -y install vim
    sudo mkdir -p /etc/openvpn
    sudo docker run --name ovpn-data -v /etc/openvpn busybox
    sudo docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -p ${var.vpc_cidr} -u udp://${google_compute_address.nat_ip.address}
  EOT
}