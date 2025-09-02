terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "ap-south-1"
}

# VPC and Subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "inventory-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# EC2 Instance
resource "aws_instance" "inventory_server" {
  ami           = "ami-0dee22c13ea7a9a67"   # Amazon Linux 2023 in ap-south-1
  instance_type = "t2.large"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = "abhay-21"   # Replace with your EC2 Key Pair name in AWS

  tags = {
    Name        = "inventory-instance"
    Environment = "dev"
    Project     = "Inventory"
  }
  resource "aws_security_group" "inventory_sg" {
  name   = "inventory-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<your-ip>/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

}
