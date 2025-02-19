provider "aws" {
  region = var.aws_region
}

# ----------------------------
# VPC, Subnets, NAT, and Route Tables
# ----------------------------

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Create Public Subnet in AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-AZ1"
  }
}

# Create Public Subnet in AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-AZ2"
  }
}

# Create Private Subnet in AZ1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Private-Subnet-AZ1"
  }
}

# Create Private Subnet in AZ2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Private-Subnet-AZ2"
  }
}

# Create NAT Gateway in Public Subnet (AZ1)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  depends_on = [aws_eip.nat_eip]
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_rta_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# Create Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table_association" "private_rta_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_rt.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main-Internet-Gateway"
  }
}

# ------------------------------
# Security Group for Nginx EC2 Instances
# ------------------------------

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow HTTP traffic to EC2 instances"
  vpc_id      = aws_vpc.main_vpc.id

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

# ------------------------------
# EC2 Instances for Nginx
# ------------------------------

resource "aws_instance" "instance_a" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  availability_zone = "us-east-1a"
  subnet_id       = aws_subnet.private_subnet_az1.id

  tags = {
    Name = "Instance-A"
  }

  user_data = file("nginx-homepage.sh")
}

resource "aws_instance" "instance_b" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  availability_zone = "us-east-1b"
  subnet_id       = aws_subnet.private_subnet_az2.id

  tags = {
    Name = "Instance-B"
  }

  user_data = file("nginx-images.sh")
}

resource "aws_instance" "instance_c" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  availability_zone = "us-east-1a"
  subnet_id       = aws_subnet.private_subnet_az1.id

  tags = {
    Name = "Instance-C"
  }

  user_data = file("nginx-register.sh")
}

# ------------------------------
# Load Balancer and Target Groups
# ------------------------------

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
}

resource "aws_lb_target_group" "tg_a" {
  name     = "tg-homepage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_target_group" "tg_b" {
  name     = "tg-images"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_target_group" "tg_c" {
  name     = "tg-register"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "This is the default response."
    }
  }
}

resource "aws_lb_listener_rule" "homepage_rule" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_a.arn
  }

  condition {
    path_pattern { 
      values = ["/"]
    }
  } 
}

resource "aws_lb_listener_rule" "images_rule" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_b.arn
  }

  condition {
    path_pattern {
      values = ["/images"]
    }
  }
}

resource "aws_lb_listener_rule" "register_rule" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_c.arn
  }

  condition {
    path_pattern {
      values = ["/register"]
    }
  } 
}

resource "aws_lb_target_group_attachment" "tg_attach_a" {
  target_group_arn = aws_lb_target_group.tg_a.arn
  target_id = aws_instance.instance_a.id
  port            = 80
}
 
resource "aws_lb_target_group_attachment" "tg_attach_b" {
  target_group_arn = aws_lb_target_group.tg_b.arn
  target_id = aws_instance.instance_b.id
  port            = 80
}
 
resource "aws_lb_target_group_attachment" "tg_attach_c" {
  target_group_arn = aws_lb_target_group.tg_c.arn
  target_id = aws_instance.instance_c.id
  port            = 80
}
# Output Load Balancer URL
output "load_balancer_url" {
  value = aws_lb.app_lb.dns_name
}


