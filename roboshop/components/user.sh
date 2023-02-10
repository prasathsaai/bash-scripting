#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=user
FUSER=roboshop

echo -e ">>> \e[41;36m Installing Catalogue \e[0m <<<"

echo -n "Configureing yum repo for NodeJS:"
curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - >> /tmp/${COMPONENT}.log
stat $?

echo -n "Installing NodeJS:"
yum install nodejs -y &>> /tmp/${COMPONENT}.log
stat $?

echo -n "Adding $FUSER User:"
id ${FUSER} >> /tmp/${COMPONENT}.log || useradd ${FUSER} 
stat $?

echo -n "Downloading ${COMPONENT} Application File:"
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" >> /tmp/${COMPONENT}.log
stat $?

echo "Cleanup of old ${COMPONENT} Files"
rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log
cd /home/${FUSER}

echo -n "Extracting ${COMPONENT} Files:"
unzip -o /tmp/${COMPONENT}.zip >> /tmp/${COMPONENT}.log
mv ${COMPONENT}-main ${COMPONENT}
stat $?

echo "Changing the Ownership to $FUSER"
chown -R $FUSER:$FUSER $COMPONENT/
cd /home/${FUSER}/${COMPONENT}

echo -n "Installing NodeJS Dependencies:"
npm install &>> /tmp/${COMPONENT}.log
stat $?

echo -n "Updating SystemD service file with REDIS and  MONGODB Endpoints:"
sed -i -e 's/MONGO_DNSNAME/mongodb.awsdevops.internal/' -e 's/REDIS_ENDPOINT/redis.awsdevops.internal/' /home/${FUSER}/${COMPONENT}/systemd.service
mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -n "Starting the $COMPONENT Service:"
systemctl daemon-reload &>> /tmp/${COMPONENT}.log
systemctl enable ${COMPONENT} &>> /tmp/${COMPONENT}.log
systemctl start ${COMPONENT} &>> /tmp/${COMPONENT}.log
stat $?


echo "****----${COMPONENT} Service Sucessfully Started----****"

