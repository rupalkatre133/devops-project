variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "ami_id" {
  default = "ami-0ec10929233384c7f" # Ubuntu AMI
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  description = "SSH key pair name"
}

