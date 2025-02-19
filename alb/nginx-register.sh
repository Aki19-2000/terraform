#!/bin/bash
# Update the syecho
sudo yum update -y
sudo yum install -y nginx
echo "register" | sudo tee /usr/share/nginx/html/index1.html
sudo service nginx start
