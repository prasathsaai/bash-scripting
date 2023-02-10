#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=catalogue
FUSER=roboshop

echo -e ">>> \e[41;36m Installing Frontend \e[0m <<<"

echo -n "Configureing yum repo for NodeJS:"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash >> /tmp/${COMPONENT}.log
stat $?

echo -n "Installing NodeJS:"
yum install nodejs -y >> /tmp/${COMPONENT}.log
stat $?

echo -n "Adding/Switching $FUSER User:"
id ${FUSER} || useradd ${FUSER}
stat $?

echo -n "Downloading ${COMPONENT} Application File:"
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo "Cleanup of old ${COMPONENT}:"
rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log

echo -n "Extracting ${COMPONENT} files:"
cd /home/${FUSER}
unzip -o /tmp/${COMPONENT}.zip >> /tmp/${COMPONENT}.log
mv ${COMPONENT}-main ${COMPONENT}
stat $?

echo -n "Changing the Ownership to $FUSER:"
chown -R $FUSER:$FUSER $COMPONENT/

echo -n "Installing NodeJS Dependencies "
cd /home/${FUSER}/${COMPONENT}
npm install >> /tmp/${COMPONENT}.log