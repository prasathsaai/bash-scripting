# validating whether the executing user is root or not
ID=$(id -u)
if [ $ID -ne 0 ]; then 
    echo -e "\e[31m Try executing the script with sudo or a root user \e[0m"
    exit 1
fi

stat () {
    if [ $1 -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure. Look for the logs \e[0m"    
fi
}


FUSER=roboshop
LOGFILE=robot.log


# roboshop user creation
USER_SETUP() {
    echo -n "Adding $FUSER user: "
    id ${FUSER} >> /tmp/${COMPONENT}.log || useradd ${FUSER} # creating user if it does not exists
    stat $?
}

DOWNLOAD_AND_EXTRACT() {
    echo -n "Downloading ${COMPONENT} Application File:"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
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
}

CONFIG_SVC() {
echo -n "Configuring the System File:"
sed -i -e 's/MONGO_DNSNAME/mongodb.awsdevops.internal/' -e 's/MONGO_ENDPOINT/mongodb.awsdevops.internal/' -e 's/REDIS_ENDPOINT/redis.awsdevops.internal/' /home/${FUSER}/${COMPONENT}/systemd.service
mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -n "Starting the $COMPONENT Service:"
systemctl daemon-reload &>> /tmp/${COMPONENT}.log
systemctl enable ${COMPONENT} &>> /tmp/${COMPONENT}.log
systemctl start ${COMPONENT} &>> /tmp/${COMPONENT}.log
stat $?
}

# NordeJS Installiation
NORDEJS() {
    echo -n "Configureing yum repo for NodeJS:"
    curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - >> /tmp/${COMPONENT}.log
    stat $?

    echo -n "Installing NodeJS:"
    yum install nodejs -y &>> /tmp/${COMPONENT}.log
    stat $?

    #calling user creation function
    USER_SETUP

    #Calling DOWNLOAD_AND_EXTRACT function
    DOWNLOAD_AND_EXTRACT

    echo -n "Installing ${COMPONENT} Dependencies:"
    npm install &>> /tmp/${COMPONENT}.log
    stat $?

    #Calling configuration function
    CONFIG_SVC
}

