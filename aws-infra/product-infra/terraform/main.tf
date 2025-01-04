/* Setup our aws provider */
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_key_pair" "deployer" {
  key_name   = "automated-vpc"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Define our vpc
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "automated"
  }
}

/* Common security group */
resource "aws_security_group" "common" {
  name        = "SG-common-automated-vpc"
  description = "common security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "common"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

/* Security group for the nat server */
resource "aws_security_group" "nat" {
  name        = "SG-nat-automated-vpc"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat"
  }
}

/* Security group for the web */
resource "aws_security_group" "web" {
  name        = "SG-web-automated-vpc"
  description = "Security group for web that allows web traffic from internet"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web"
  }
}