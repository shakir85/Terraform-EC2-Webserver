provider "aws" {
  region = "us-east-1"
}
# PART 1.2
# PROVISION INFRASTRUCTURE
# LAUNCH A VPC WITH ALL NETWORKING RELATED PARTS

# VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Production-VPC"
    }
}

# Internet Getway
resource "aws_internet_gateway" "prod-ig" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
      Name = "Production-Internet-Gateway"
  }
}

# Routing Table
resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id
  # IPv4 routing
  route {
      cidr_block = "0.0.0.0/0" 
      gateway_id = aws_internet_gateway.prod-ig.id
  }
  # IPv6 routing
  route {
      ipv6_cidr_block = "::/0" 
      gateway_id = aws_internet_gateway.prod-ig.id
  }
  tags = {
      Name = "Production-Routing-Table"
  }
}

# Subnetting
resource "aws_subnet" "prod-subnet" {
  vpc_id = aws.vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
      Name = "Production-Public-Subnet"
  }
}

# Subnet - Routing Table association (Public)
resource "aws_route_table_association" "prod-rsa" {
  subnet_id = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-rt.id
}

# SecGroup for SSH & HTTP (ports 22 & 80)
# Note: below CIDR block is a wide open SSH! which is insecure & not-recommended
# It's only for testing purposes and it shouldn't be in a real-production environment
resource "aws_security_group" "prod-sg" {
  name = "allow-traffic"
  description = "Allow SSH and HTTP traffic"

  # SSH
  ingress {
      description "Allow SSH traffic from anywhere"
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP
  ingress {
      description = "Allow inbound traffic for HTTP on port 80"
      from_port = "80"
      to_port = "80"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "Security-Group-Public-Wideopen"
  }

# Create ENI & attach ealstic IP from our subnet
resource "aws_eip" "prod-eni" {
  vpc = "true"
  network_interface = aws_network_interface.prod-eni.id
  associate_with_private_ip = "10.0.1.10"
  depends_on = [aws_internet_gateway.prod-ig]
  tags = {
      Name = "Elastic IP"
  }
}


# PART 2.2
# PROVISION EC2 INSTANCE
# LAUNCH & CONFIGURE APACHE SERVER

# EC2 instance using Linux Ubuntu
# For Ubuntu AMI locator use this: https://cloud-images.ubuntu.com/locator/ec2/
resource "aws_insrance" "prod-insrance" {
    ami = "ami-08a5419d45846dbc5"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "firts-key-production"

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.prod-eni.id
    }
    # Install & launch Apacher server
    user_data = <<-EOF
                #! /bin/bash
                systemctl start httpd.service
                systemctl enable httpd.service
                echo "Hello world from $(hostname -f)" > /var/www/html/index.html
    tags = {
        Name = "Web-Server"
    }
}
}
