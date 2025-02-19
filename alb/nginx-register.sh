#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
echo "Register Content" | sudo tee /usr/share/nginx/html/register.html
sudo service nginx start
