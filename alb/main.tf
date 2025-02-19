provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow HTTP traffic to EC2 instances"
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

resource "aws_instance" "instance_a" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.nginx_sg.name]
  availability_zone = "us-east-1a"

  tags = {
    Name = "Instance-A"
  }

  user_data = file("nginx-homepage.sh")
}

resource "aws_instance" "instance_b" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.nginx_sg.name]
  availability_zone = "us-east-1b"

  tags = {
    Name = "Instance-B"
  }

  user_data = file("nginx-images.sh")
}

resource "aws_instance" "instance_c" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.nginx_sg.name]
  availability_zone = "us-east-1c"

  tags = {
    Name = "Instance-C"
  }

  user_data = file("nginx-register.sh")
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "tg_a" {
  name     = "tg-homepage"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "tg_b" {
  name     = "tg-images"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "tg_c" {
  name     = "tg-register"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
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
    field  = "path-pattern"
    values = ["/"]
  }
}

resource "aws_lb_listener_rule" "images_rule" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_b.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/images"]
  }
}

resource "aws_lb_listener_rule" "register_rule" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_c.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/register"]
  }
}

output "load_balancer_url" {
  value = aws_lb.app_lb.dns_name
}
