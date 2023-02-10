#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

echo -e ">>> \e[41;36m Installing Frontend \e[0m <<<"

echo -n "Installing Nginx:"
yum install nginx -y >> /tmp/frontend.log
stat $?

systemctl enable nginx >> /tmp/frontend.log

echo -n "Starting Nginx:"
systemctl start nginx
stat $?

echo -n "Downloading the application files:"
curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"
stat $?

cd /usr/share/nginx/html
rm -rf *

echo -n "Extracting the Code:"
unzip -o /tmp/frontend.zip >> /tmp/frontend.log
stat $?

mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md

echo -n "Performing Cleanup:"
mv localhost.conf /etc/nginx/default.d/roboshop.conf

echo -n "Restarting Nginx:"
systemctl restart nginx
stat $?