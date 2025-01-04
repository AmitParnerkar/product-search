variable "access_key" {
  description = "AWS access key"
  sensitive = true
}

variable "secret_key" {
  description = "AWS secret access key"
  sensitive = true
}

variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "az" {
  description = "AWS availability_zone"
  default     = "us-west-1a"
}