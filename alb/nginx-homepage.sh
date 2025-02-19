#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
echo "Homepage Content" | sudo tee /usr/share/nginx/html/index.html
sudo service nginx start
