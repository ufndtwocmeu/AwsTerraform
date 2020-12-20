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
  default = "t2.micro"
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
resource "aws_security_group" "allow_tomcat" {
  name        = "allow_tomcat"
  description = "Allow traffic for Tomcat"
  vpc_id      = var.my_vpc_id

  ingress {
    description = "Incoming tcp at 8080 from everywhere"
    from_port   = 8080
    to_port     = 8080
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
    Name = "allow_tomcat"
  }
}





# Create buider instance
resource "aws_instance" "build_instance" {
  ami = var.image_id
  instance_type = var.inst_type
  vpc_security_group_ids = [aws_security_group.allow_tomcat.id]
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk maven git awscli
mkdir /data && cd /data && git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd /data/boxfuse-sample-java-war-hello && mvn package
export AWS_ACCESS_KEY_ID=${var.my_access_key}
export AWS_SECRET_ACCESS_KEY=${var.my_secret_key}
export AWS_DEFAULT_REGION=${var.deploy_region}
aws s3 cp /data/boxfuse-sample-java-war-hello/target/hello-1.0.war ${var.my_bucket}
EOF
  
}

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


