# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# VPC Creation
resource "aws_vpc" "main" {# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# VPC Creation
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet for Web Tier
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnet for Database Tier
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}

# Route Tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Public route table association
resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for Web Servers
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# EC2 Instance for Web Servers
resource "aws_instance" "web_server_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  security_group = aws_security_group.web_sg.id
  associate_public_ip_address = true
  key_name = "your-key-name"  # Replace with your SSH key name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              service httpd start
              chkconfig httpd on
              echo "Web Server 1" > /var/www/html/index.html
            EOF

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  security_group = aws_security_group.web_sg.id
  associate_public_ip_address = true
  key_name = "your-key-name"  # Replace with your SSH key name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              service httpd start
              chkconfig httpd on
              echo "Web Server 2" > /var/www/html/index.html
            EOF

  tags = {
    Name = "web-server-2"
  }
}

# Security Group for Database Server
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_1.cidr_block, aws_subnet.private_subnet_2.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MySQL instance in Private Subnets
resource "aws_db_instance" "my_db" {
  identifier        = "mydb-instance"
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  db_name           = "mydb"
  username          = "admin"
  password          = "password123"  # Use AWS Secrets Manager for sensitive info
  subnet_group_name = aws_db_subnet_group.my_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az          = false
  publicly_accessible = false
  tags = {
    Name = "MyDatabase"
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "my_subnet_group" {
  name        = "my-subnet-group"
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "MyDatabaseSubnetGroup"
  }
}

  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet for Web Tier
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnet for Database Tier
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}

# Route Tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Public route table association
resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for Web Servers
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# EC2 Instance for Web Servers
resource "aws_instance" "web_server_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  security_group = aws_security_group.web_sg.id
  associate_public_ip_address = true
  key_name = "your-key-name"  # Replace with your SSH key name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              service httpd start
              chkconfig httpd on
              echo "Web Server 1" > /var/www/html/index.html
            EOF

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  security_group = aws_security_group.web_sg.id
  associate_public_ip_address = true
  key_name = "your-key-name"  # Replace with your SSH key name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              service httpd start
              chkconfig httpd on
              echo "Web Server 2" > /var/www/html/index.html
            EOF

  tags = {
    Name = "web-server-2"
  }
}

# Security Group for Database Server
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_1.cidr_block, aws_subnet.private_subnet_2.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MySQL instance in Private Subnets
resource "aws_db_instance" "my_db" {
  identifier        = "mydb-instance"
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  db_name           = "mydb"
  username          = "admin"
  password          = "password123"  # Use AWS Secrets Manager for sensitive info
  subnet_group_name = aws_db_subnet_group.my_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az          = false
  publicly_accessible = false
  tags = {
    Name = "MyDatabase"
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "my_subnet_group" {
  name        = "my-subnet-group"
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "MyDatabaseSubnetGroup"
  }
}
