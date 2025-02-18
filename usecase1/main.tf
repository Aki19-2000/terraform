data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

   tags = {
    Name = "main-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Create Private Subnets
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1] 
  tags = {
    Name = "private-subnet-2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}


# Create NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id
   tags = {
    Name = "main-nat"
  }
}

# Create Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
   tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
   tags = {
    Name = "private-route-table"
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# Create Security Groups
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

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

   tags = {
    Name = "web-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db-sg"
  }
}

# Create EC2 Instances for Web Servers with Database Connection Example
resource "aws_instance" "web1" {
  ami           = "ami-053a45fff0a704a47"
  instance_type = "t3.micro"
  #availability_zone    = "us-east-1a" 
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2 php libapache2-mod-php php-mysql
              systemctl start apache2
              systemctl enable apache2

              echo "<?php
              \$servername = '${aws_db_instance.app_db.endpoint}';
              \$username = 'admin';
              \$password = 'password123';
              \$dbname = 'mydb';

              // Create connection
              \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

              // Check connection
              if (\$conn->connect_error) {
                die('Connection failed: ' . \$conn->connect_error);
              }

              \$sql = 'SELECT id, name FROM users';
              \$result = \$conn->query(\$sql);

              if (\$result->num_rows > 0) {
                while(\$row = \$result->fetch_assoc()) {
                  echo 'id: ' . \$row['id']. ' - Name: ' . \$row['name']. '<br>';
                }
              } else {
                echo '0 results';
              }
              \$conn->close();
              ?>" > /var/www/html/index.php
              EOF
}

resource "aws_instance" "web2" {
  ami           = "ami-053a45fff0a704a47"
  instance_type = "t3.micro"
  #availability_zone    = "us-east-1a" 
  subnet_id     = aws_subnet.public2.id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-2"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2 php libapache2-mod-php php-mysql
              systemctl start apache2
              systemctl enable apache2

              echo "<?php
              \$servername = '${aws_db_instance.app_db.endpoint}';
              \$username = 'admin';
              \$password = 'password123';
              \$dbname = 'mydb';

              // Create connection
              \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

              // Check connection
              if (\$conn->connect_error) {
                die('Connection failed: ' . \$conn->connect_error);
              }

              \$sql = 'SELECT id, name FROM users';
              \$result = \$conn->query(\$sql);

              if (\$result->num_rows > 0) {
                while(\$row = \$result->fetch_assoc()) {
                  echo 'id: ' . \$row['id']. ' - Name: ' . \$row['name']. '<br>';
                }
              } else {
                echo '0 results';
              }
              \$conn->close();
              ?>" > /var/www/html/index.php
              EOF
}

resource "aws_db_subnet_group" "default" {
  name       = "main1"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# Create RDS MySQL Instance
resource "aws_db_instance" "app_db" {
  identifier = "my-rds-instance"
  allocated_storage    = var.db_allocated_storage
  instance_class       = var.db_instance_class
  engine               = var.db_engine
  username             = "admin"   
  password             = "password123" 
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  multi_az               = true
  


  tags = {
    Name        = "app-db"
      }
}

output "rds_endpoint" {
  value = aws_db_instance.app_db.endpoint
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "Database engine version"
  default     = "mysql"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance"
  default     = 20
}
