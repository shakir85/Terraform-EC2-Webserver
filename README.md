# Terraform-EC2-Webserver
Terraform template to launch VPC, EC2, and Apache Webserver

# What is included?
1. VPC launch and configurations including: Routing tables, Subnetting, Internet-Gateway, Rout-tables - Gateway association.
2. Security Group: allow inbound and outbound roles for SSH (port 20) and HTTP (port 80) with the desired CIDR blocks.
3. Launching an Elastic Network Interface to serve EIP.
4. Launching EC2 T2 Micro instance to serve as web-server.
5. Associate ENI with EC2.
6. Boot strapping user data to EC2 instance to install and configure Apache server right upon the instance's launch.

# Improvements
This template is for testing purposes. There are many ways that we could improve the template to be more versatile. The following are some improvement examples:

- Using Terraform variables for resource references. For example, using a variable that determines the AMI type based on what region the template is configured to.
- Using separate shell script for EC2 user data to accommodate more configuration scripts and reference this script file inside Terraform template.