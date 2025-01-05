# App Servers (Equivalent to AWS EC2 instances)
resource "google_compute_instance" "app" {
  count             = 2
  name              = "app-${count.index}"
  machine_type      = "e2-standard-4" # Adjust machine type as needed
  zone              = "${var.region}-a"  # GCP zone, similar to AWS Availability Zone
  project           = var.project_id
  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20241218"  # You can specify the image you need
      size  = 50  # Increase root disk size to 50 GB
    }
  }

  # Network interface
  network_interface {
    network    = data.terraform_remote_state.network.outputs.network_name  # Use network from remote state
    subnetwork = data.terraform_remote_state.network.outputs.private_subnet_id  # Subnet from remote state
    access_config {
      # Public IP, remove if you don't need public IP for instances
    }
  }

  tags = ["app-server"]
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}" # SSH keys from local machine
  }

  # User data configuration for app setup (equivalent to AWS user_data)
  metadata_startup_script = file("app-config/app.yaml")
}

# Load Balancer (GCP equivalent to AWS ELB)
resource "google_compute_backend_service" "app" {
  name        = "automated-app-backend"
  protocol    = "HTTP"
  project     = var.project_id

  backend {
    group = google_compute_instance_group.app_instances.self_link
  }

  health_checks = [google_compute_health_check.http_health_check.self_link]
}

# Global Forwarding Rule to route traffic to the backend service
# resource "google_compute_global_forwarding_rule" "http_rule" {
#   name       = "app-http-forwarding-rule"
#   project    = var.project_id
#   target     = google_compute_backend_service.app.self_link  # Correct backend service self-link
#   port_range = "80"
#   ip_address = google_compute_address.lb_ip.address  # IP address for the load balancer
# }

# HTTP Health Check for Load Balancer
resource "google_compute_health_check" "http_health_check" {
  name               = "http-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
  project           = var.project_id
  http_health_check {
    port = 80
    request_path = "/"
  }
}

# Instance Group (for managing app instances in the backend)
resource "google_compute_instance_group" "app_instances" {
  name        = "app-instance-group"
  project     = var.project_id
  zone        = "${var.region}-a"
  instances   = google_compute_instance.app.*.self_link  # Instances created previously
}

# Static IP for Load Balancer (Global)
resource "google_compute_address" "lb_ip" {
  name         = "lb-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"  # Ensure it's an external IP
}
