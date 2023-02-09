#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

echo -e ">>> \e[41;36m Installing Frontend \e[0m <<<"

echo "Installing Nginx"

yum install nginx -y >> /tmp/frontend.log
systemctl enable nginx

echo "Starting Nginx:"
systemctl start nginx

curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"

cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip >> /tmp/frontend.log
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf

systemctl restart nginx