# Setup our Google provider
provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.project_id
  region      = var.region
}

# App Servers (Equivalent to AWS EC2 instances)
resource "google_compute_instance" "app" {
  count             = 2
  name              = "${data.terraform_remote_state.network.outputs.network}-product-app-${count.index}"
  machine_type      = "e2-standard-4" # Adjust machine type as needed
  zone              = "${var.region}-a"  # GCP zone, similar to AWS Availability Zone
  can_ip_forward    = true

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20241218"  # You can specify the image you need
      size  = 50  # Increase root disk size to 50 GB
    }
  }

  # Network interface
  network_interface {
    network    = data.terraform_remote_state.network.outputs.network  # Use network from remote state
    subnetwork = data.terraform_remote_state.network.outputs.private_subnet_name  # Subnet from remote state
  }

  # assign security groups
  tags = [data.terraform_remote_state.network.outputs.common_security_group_ingress,
    data.terraform_remote_state.network.outputs.common_security_group_egress,
    google_compute_firewall.allow_lb_to_private_subnet.name]

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}" # SSH keys from local machine
  }

  # User data configuration for app setup (equivalent to AWS user_data)
  metadata_startup_script = <<EOT
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker ubuntu
  sudo apt-get -y install vim
  sudo wget -O /home/ubuntu/docker-compose.yaml https://gist.githubusercontent.com/AmitParnerkar/7d9305369284000be0b34951c634ef12/raw/f37ac57d1a9ba686b9660fe38ef79fcd45ca9603/docker-compose.yaml
  cd /home/ubuntu
  sudo docker compose up -d
  EOT
}

//* Load balancer - HTTP(S) */
resource "google_compute_global_address" "lb_ip" {
  name = "${data.terraform_remote_state.network.outputs.network}-product-app-lb-ip"
}

resource "google_compute_backend_service" "app_backend" {
  name        = "${data.terraform_remote_state.network.outputs.network}-product-app-backend-service"
  health_checks = [google_compute_http_health_check.app_health_check.self_link]
  backend {
    group = google_compute_instance_group.app_group.self_link
  }
}

resource "google_compute_firewall" "allow_lb_to_private_subnet" {
  name    = "${data.terraform_remote_state.network.outputs.network}-allow-lb-health-check"
  network = data.terraform_remote_state.network.outputs.network

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"] # Update these ports as per your app
  }

  source_ranges = ["0.0.0.0/0"] # Load balancer health check IPs

  target_tags = ["${data.terraform_remote_state.network.outputs.network}-allow-lb-health-check"] # Add this tag to your app instances
}

resource "google_compute_instance_group" "app_group" {
  name    = "${data.terraform_remote_state.network.outputs.network}-product-app-group"
  zone    = "${var.region}-a"
  instances = google_compute_instance.app.*.self_link
}

resource "google_compute_http_health_check" "app_health_check" {
  name                = "${data.terraform_remote_state.network.outputs.network}-product-app-health-check"
  request_path        = "/"
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

resource "google_compute_url_map" "app_url_map" {
  name            = "${data.terraform_remote_state.network.outputs.network}-product-app-url-map"
  default_service = google_compute_backend_service.app_backend.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name        = "${data.terraform_remote_state.network.outputs.network}-product-app-http-proxy"
  url_map     = google_compute_url_map.app_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "${data.terraform_remote_state.network.outputs.network}-product-app-http-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy.self_link
}

/* Google-managed SSL Certificate */
resource "google_compute_managed_ssl_certificate" "https_cert" {
  name =  "${data.terraform_remote_state.network.outputs.network}-product-app-ssl-cert"
  managed {
    domains = ["spinachsoftware.com"] # Replace with your domain
  }
}

/* HTTPS Target Proxy */
resource "google_compute_target_https_proxy" "https_proxy" {
  name        = "${data.terraform_remote_state.network.outputs.network}-product-app-https-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.https_cert.self_link]
  url_map     = google_compute_url_map.app_url_map.self_link
}

/* HTTPS Global Forwarding Rule */
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "${data.terraform_remote_state.network.outputs.network}-product-app-https-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "443"
  target     = google_compute_target_https_proxy.https_proxy.self_link
}