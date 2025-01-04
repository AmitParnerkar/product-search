/* App servers */
resource "aws_instance" "app" {
  count             = 2
  ami               = var.amis[var.region]
  instance_type     = "t2.2xlarge"
  subnet_id         = data.terraform_remote_state.network.outputs.private_subnet_id
  security_groups   = [data.terraform_remote_state.network.outputs.common_security_group_id]
  key_name          = data.terraform_remote_state.network.outputs.deployer_key_name
  source_dest_check = true
  root_block_device {
    volume_size = 50  # Increase the root volume size to 50 GB
    volume_type = "gp2"
  }
  user_data         = file("app-config/app.yaml")
  tags = {
    Name = "automated-app-${count.index}"
  }
}

/* Load balancer */
resource "aws_elb" "app" {
  name            = "automated-vpc-elb"
  subnets         = [data.terraform_remote_state.network.outputs.public_subnet_id]
  security_groups = [data.terraform_remote_state.network.outputs.common_security_group_id,
    data.terraform_remote_state.network.outputs.security_web_id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 15
  }

  instances = aws_instance.app.*.id
}