#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

echo -e ">>> \e[41;36m Installing Frontend \e[0m <<<"

echo "Installing Nginx"

yum install nginx -y >> /tmp/frontend.log

if [ $? -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure. Look for the logs \e[0m"    
fi

systemctl enable nginx

echo "Starting Nginx:"

systemctl start nginx

if [ $? -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure. Look for the logs \e[0m"    
fi

echo "Downloading the application files"

curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"

if [ $? -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure. Look for the logs \e[0m"    
fi

cd /usr/share/nginx/html
rm -rf *
unzip -o /tmp/frontend.zip >> /tmp/frontend.log
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf

systemctl restart nginx