variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t3.small"
}

variable "ami_id" {
  default = "ami-0ec10929233384c7f"
}

variable "key_name" {
  description = "Your EC2 key pair"
}

variable "allowed_ip" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
