#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
sudo mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index-orig.html
echo "This is Nginx server from Terraform" > /usr/share/nginx/html/index.html
sudo service nginx start
