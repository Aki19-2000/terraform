#!/bin/bash
# Update the syecho
sudo yum update -y
sudo yum install -y nginx
echo "image" | sudo tee /usr/share/nginx/html/index.html
sudo service nginx start
