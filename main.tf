# main.tf

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"  # Changed region to us-east-1
}

# VPC Definition
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Public Subnet 1 (Web Tier)
resource "aws_subnet" "web_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Changed to us-east-1a
  map_public_ip_on_launch = true
  tags = {
    Name = "web-subnet-1"
  }
}

# Public Subnet 2 (Web Tier)
resource "aws_subnet" "web_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"  # Changed to us-east-1b
  map_public_ip_on_launch = true
  tags = {
    Name = "web-subnet-2"
  }
}

# Private Subnet 1 (Database Tier)
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"  # Changed to us-east-1a
  tags = {
    Name = "db-subnet-1"
  }
}

# Private Subnet 2 (Database Tier)
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"  # Changed to us-east-1b
  tags = {
    Name = "db-subnet-2"
  }
}

# Security Group for Web Servers
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Security Group for Database (RDS)
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL traffic from web servers"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for Web Server 1 (Apache/Nginx)
resource "aws_instance" "web_server_1" {
  ami           = "ami-xyz"  # Use appropriate AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet_1.id
  security_groups = [aws_security_group.web_sg.name]
  
  tags = {
    Name = "WebServer-1"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
              EOF
}

# EC2 Instance for Web Server 2 (Apache/Nginx)
resource "aws_instance" "web_server_2" {
  ami           = "ami-xyz"  # Use appropriate AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet_2.id
  security_groups = [aws_security_group.web_sg.name]
  
  tags = {
    Name = "WebServer-2"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
              EOF
}

# RDS MySQL Instance (Database Tier)
resource "aws_db_instance" "my_db" {
  identifier        = "mydb-instance"
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  db_name           = "mydb"
  username          = "admin"
  password          = "password"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az          = true
  subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  tags = {
    Name = "my-db-instance"
  }
}

# DynamoDB for State Locking (for remote state management)
resource "aws_dynamodb_table" "my_lock_table" {
  name         = "terraform-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# S3 Bucket for Remote State Management
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-terraform-state"
  acl    = "private"
}
