#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=mongodb

echo -e ">>> \e[41;36m Installing Frontend \e[0m <<<"

# Downloading MongoDB server
echo -n "Configuring the ${COMPONENT} repo:"
curl -s -o /etc/yum.repos.d/${COMPONENT}.repo https://raw.githubusercontent.com/stans-robot-project/mongodb/main/mongo.repo
stat $?

# Installing MongoDB
echo -n "Installing ${COMPONENT} Server:"
yum install -y mongodb-org >> /tmp/${COMPONENT}.log
stat $?

echo -n "Updating ${COMPONENT} Config:"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
stat $?

echo -n "Starting ${COMPONENT} Service:"
systemctl enable mongod >> /tmp/${COMPONENT}.log
systemctl start mongod
stat $?

echo -n "Downloading ${COMPONENT} schema:"
curl -s -L -o /tmp/mongodb.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo -n "Injecting Schema to ${COMPONENT} "
cd /tmp && unzip mongodb.zip && cd mongodb-main
mongo < catalogue.js # Injecting Catalogue Table
mongo < users.js # Injecting User Table
stat $?