variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "ami_id" {
  default = "ami-0ec10929233384c7f"
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  default = "pemvirginia2"
}

variable "allowed_ip" {
  default = ["0.0.0.0/0"]
}
