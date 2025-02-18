resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP traffic to the web server"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Choose a region-specific AMI for Ubuntu or Amazon Linux
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.web_sg.name]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF
}

resource "aws_instance" "web_instance_2" {
  ami           = "ami-085ad6ae776d8f09c" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  security_groups = [aws_security_group.web_sg.name]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF
}
