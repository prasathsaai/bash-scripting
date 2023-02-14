#!/bin/bash

set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not 

echo ">>> /e[43;36m Installing Shipping /e[0m <<<"

COMPONENT=shipping
LOGFILE=robot.log
Install Maven
yum install maven -y   # installs maven with java 8

USER_SETUP

echo "Changing the Ownership to $FUSER"
chown -R $FUSER:$FUSER $COMPONENT/
cd /home/${FUSER}/${COMPONENT}

cd /home/${FUSER}
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/shipping/archive/main.zip" &>> ${LOGFILE}
unzip /tmp/${COMPONENT}.zip &>> ${LOGFILE}
mv ${COMPONENT}-main ${COMPONENT}
cd ${COMPONENT}
mvn clean package &>> ${LOGFILE}
mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar

CONFIG_SVC