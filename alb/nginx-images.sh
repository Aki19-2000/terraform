#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
echo "Image Content" | sudo tee /usr/share/nginx/html/images.html
sudo service nginx start
