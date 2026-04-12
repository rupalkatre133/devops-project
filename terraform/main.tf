terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------------- VPC ----------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "main-vpc"
  cidr = var.vpc_cidr

  azs            = ["${var.region}a", "${var.region}b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # ✅ IMPORTANT FIX
  map_public_ip_on_launch = true

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# ---------------- Security Group ----------------
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins UI"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip
  }

  ingress {
    description = "App Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- Jenkins EC2 ----------------
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = module.vpc.public_subnets[0]

  associate_public_ip_address = true  # ✅ IMPORTANT

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y

              apt install -y openjdk-17-jdk docker.io git wget

              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              wget -O /usr/share/keyrings/jenkins-keyring.asc \
                https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/" \
                > /etc/apt/sources.list.d/jenkins.list

              apt update -y
              apt install -y jenkins

              systemctl start jenkins
              systemctl enable jenkins

              usermod -aG docker jenkins
              systemctl restart jenkins
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

# ---------------- EKS ----------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  cluster_name    = "ci-cd-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # ✅ IMPORTANT FIX
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3

      instance_types = ["t3.small"]

      # ✅ IMPORTANT FIX
      subnet_ids = module.vpc.public_subnets
    }
  }

  tags = {
    Environment = "dev"
  }
}
