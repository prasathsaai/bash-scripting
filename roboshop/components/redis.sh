#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=redis

echo -e ">>> \e[41;36m Installing Redis \e[0m <<<"

echo -n "Configuring the ${COMPONENT} repo:"
curl -l https://raw.githubusercontent.com/stans-robot-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>> /tmp/${COMPONENT}.log
stat $?

echo -n "Installing Redis:"
yum install redis-6.2.9 -y >> /tmp/${COMPONENT}.log
stat $?

echo -n "Updating ${COMPONENT} Config:"
sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/${COMPONENT}.conf
sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/${COMPONENT}/${COMPONENT}.conf
stat $?

echo -n "Starting ${COMPONENT}:"
systemctl enable redis &>> /tmp/${COMPONENT}.log
systemctl start redis
stat $?

echo "****----${COMPONENT} Service Sucessfully Started----****"