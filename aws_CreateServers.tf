terraform {
  required_providers {
    aws = {
      version = "3.22.0"
    }
  }
}


# Define access and secret key for aws in variables
variable "my_access_key" {
  default = "enter-your-access-key-here!!!!!!!!!!!!"
} 
variable "my_secret_key" {
  default = "enter-your-secret-key-here!!!!!!!!!!!!"
} 

# Define my bucket name in a variable
variable "my_bucket" {
  default = "s3://mybacket1.ufndtwocmeu.ru"
} 

# Define instance type in a variable
variable "inst_type" {
  default = "t2.medium"
} 

# Define region in a variable
variable "deploy_region" {
  default = "us-east-2"
} 

# Define varibale for EC2 ubuntu18.04 image for us-east-2 aws region
variable "image_id" {
  default = "ami-0dd9f0e7df0f0a138"
}

# Define VPC in a variable
variable "my_vpc_id" {
  default = "vpc-8d8f30e6"
}



# Configure the AWS Provider
provider "aws" {
  region = var.deploy_region
  access_key = var.my_access_key
  secret_key = var.my_secret_key
}




# Create security rules for deploy
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow traffic for ssh"
  vpc_id      = var.my_vpc_id

  ingress {
    description = "Incoming ssh at 22 from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outcoming traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "my_key {
  key_name   = "my_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAizlKykSxayQNA9PKrwT44VpirQSALkiYA9tbL39Am6zB25FeOWGXuIEVJHCT8bPhDuqISJJemOSZI5ps4EuoyBfnU/EdUQ8M+Tp3Fl8+PuEk85q41UdT/IJIWlUnrvd6HK9TIUPZWP795qcq8it6fSIvHBOp0q3AFIAejKxvCED4qSoUo5CAJwowXaGApjJi/19xtwf1tHeuaQE084NUCf/EPatXQo3Y2ntvSAkbaNlZnyS9bRMTXZyp9BS1jliby297uKpWnGyoeTNOyG4Euufx3CZxJFV6LIrrcNdLbAm/03WP5p2ODGa5Db8FzRCQw/e6E/YkSzFykNAaZmQz4w== rsa-key-20201104"
} 

# Create server1
resource "aws_instance" "server1" {
  ami = var.image_id
  instance_type = var.inst_type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = aws_key_pair.my_key.key_name 
  user_data = <<EOF
#!/bin/bash
sudo apt update && apt -y upgrade apt install -y awscli
export AWS_ACCESS_KEY_ID=${var.my_access_key}
export AWS_SECRET_ACCESS_KEY=${var.my_secret_key}
export AWS_DEFAULT_REGION=${var.deploy_region}
EOF


# Create server2
resource "aws_instance" "server2" {
  ami = var.image_id
  instance_type = var.inst_type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = aws_key_pair.my_key.key_name
  user_data = <<EOF
#!/bin/bash
sudo apt update && apt -y upgrade apt install -y awscli
export AWS_ACCESS_KEY_ID=${var.my_access_key}
export AWS_SECRET_ACCESS_KEY=${var.my_secret_key}
export AWS_DEFAULT_REGION=${var.deploy_region}
EOF
  
}

/*
# Create production instance
resource "aws_instance" "prod_instance" {
  ami = var.image_id
  instance_type = var.inst_type
  vpc_security_group_ids = [aws_security_group.allow_tomcat.id]
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk tomcat8 awscli
export AWS_ACCESS_KEY_ID=${var.my_access_key}
export AWS_SECRET_ACCESS_KEY=${var.my_secret_key}
export AWS_DEFAULT_REGION=${var.deploy_region}
aws s3 cp ${var.my_bucket}/hello-1.0.war /var/lib/tomcat8/webapps/hello-1.0.war
sudo systemctl restart tomcat8
EOF
  
}

*/
