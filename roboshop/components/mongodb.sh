#!/bin/bash

source components/common.sh  # Validating the excuting user is root or not

echo -e ">>> \e[41;36m Installing Frontend \e[0m <<<"

# Downloading MongoDB server
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/stans-robot-project/mongodb/main/mongo.repo

# Installing MongoDB
yum install -y mongodb-org
systemctl enable mongod
systemctl start mongod
