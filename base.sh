#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start
sudo echo `wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document` > /var/www/html/index.html