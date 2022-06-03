#! /bin/bash

yum update -y
yum install -y httpd git
systemctl enable --now httpd 

cd /var/www/
git clone <##GIT##>