#!/bin/bash

source components/common.sh  # Validating the excuting user is root or not

echo ">>> /e[43;36m Installing Frontend /e[0m <<<"

sudo su
yum install nginx -y
systemctl enable nginx
systemctl start nginx
curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
systemctl restart nginx