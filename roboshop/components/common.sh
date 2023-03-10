# validating whether the executing user is root or not
ID=$(id -u)
if [ $ID -ne 0 ]; then 
    echo -e "\e[31m Try executing the script with sudo or a root user \e[0m"
    exit 1
fi 

# Declaring the stat function
stat() {
    if [ $1 -eq 0 ] ; then 
        echo -e "\e[32m Success \e[0m" 
    else
        echo -e "\e[31m Failure. Look for the logs \e[0m"  
    fi 
}

FUSER=roboshop 
LOGFILE=/tmp/robot.log 

USER_SETUP() {
    echo -n "Adding $FUSER user:"
    id ${FUSER} &>> LOGFILE  || useradd ${FUSER}   # Creates users only in case if the user account doen's exist
    stat $? 
}

DOWNLOAD_AND_EXTRACT() {
    echo -n "Downloading ${COMPONENT} :"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" >> /tmp/${COMPONENT}.log 
    stat $? 

    echo -n "Cleanup of Old ${COMPONENT} content:"
    rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log 
    stat $?

    echo -n "Extracting ${COMPONENT} content: "
    cd /home/${FUSER}/ >> /tmp/${COMPONENT}.log 
    unzip -o  /tmp/${COMPONENT}.zip  >> /tmp/${COMPONENT}.log   &&   mv ${COMPONENT}-main ${COMPONENT} >> /tmp/${COMPONENT}.log 
    stat $? 

    echo -n "Changing the ownership to ${FUSER}:"
    chown -R $FUSER:$FUSER $COMPONENT/
    stat $?
} 

CONFIG_SVC() {
    echo -n "Configuring the Systemd file: "
    sed -i -e 's/CARTHOST/cart.awsdevops.internal/' -e 's/USERHOST/user.awsdevops.internal/' -e 's/AMQPHOST/rabbitmq.awsdevops.internal/' -e 's/CARTENDPOINT/cart.awsdevops.internal/' -e 's/DBHOST/mysql.awsdevops.internal/' -e 's/REDIS_ENDPOINT/redis.awsdevops.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.awsdevops.internal/' -e 's/MONGO_DNSNAME/mongodb.awsdevops.internal/'  -e 's/MONGO_ENDPOINT/mongodb.awsdevops.internal/' /home/${FUSER}/${COMPONENT}/systemd.service 
    mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
    stat $? 

    echo -n "Starting the service"
    systemctl daemon-reload  &>> /tmp/${COMPONENT}.log 
    systemctl enable ${COMPONENT} &>> /tmp/${COMPONENT}.log
    systemctl start ${COMPONENT} &>> /tmp/${COMPONENT}.log
    stat $?
}

NODEJS() {
    echo -n "Configure Yum Remos for nodejs:"
    curl -sL https://rpm.nodesource.com/setup_16.x | bash >> /tmp/${COMPONENT}.log 
    stat $?

    echo -n "Installing nodejs:"
    yum install nodejs -y >> /tmp/${COMPONENT}.log 
    stat $? 
    
    # Calling User creation function
    USER_SETUP 

    # Calling Download and extract function
    DOWNLOAD_AND_EXTRACT

    echo -n "Installing $COMPONENT Dependencies:"
    cd $COMPONENT && npm install &>> /tmp/${COMPONENT}.log 
    stat $? 
    
    # Calling Config_SVC Function
    CONFIG_SVC

    echo -e "\n ************ $Component Installation Completed ******************** \n"

}


MAVEN() {
    echo -n "Installing Maven: "
    yum install maven -y &>> LOGFILE
    stat $? 

    USER_SETUP

    DOWNLOAD_AND_EXTRACT
    
    echo -n "Generating the artifact :"
    cd /home/${FUSER}/${COMPONENT}
    mvn clean package   &>> LOGFILE
    mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar
    stat $? 
    
    CONFIG_SVC

    echo -e "\n ************ $Component Installation Completed ******************** \n"

}



PYTHON() {
    echo -n "Installing Pyhton:"
    yum install python36 gcc python3-devel -y &>> ${LOGFILE} 
    stat $? 

    USER_SETUP

    DOWNLOAD_AND_EXTRACT

    cd /home/${FUSER}/${COMPONENT}/
    pip3 install -r requirements.txt   &>> ${LOGFILE} 
    stat $? 

    USER_ID=$(id -u roboshop)
    GROUP_ID=$(id -g roboshop)

    echo -n "Updating the $COMPONENT.ini file"
    sed -i -e "/^uid/ c uid=${USER_ID}" -e "/^gid/ c gid=${GROUP_ID}" payment.ini
    stat $? 

    CONFIG_SVC
}


# validating whether the executing user is root or not
# ID=$(id -u)
# if [ $ID -ne 0 ]; then 
#     echo -e "\e[31m Try executing the script with sudo or a root user \e[0m"
#     exit 1
# fi

# stat () {
#     if [ $1 -eq 0 ]; then
#     echo -e "\e[32m Success \e[0m"
# else
#     echo -e "\e[31m Failure. Look for the logs \e[0m"    
# fi
# }


# FUSER=roboshop
# LOGFILE=/tmp/robot.log


# # roboshop user creation
# USER_SETUP() {
#     echo -n "Adding $FUSER user: "
#     id ${FUSER} >> /tmp/${COMPONENT}.log || useradd ${FUSER} # creating user if it does not exists
#     stat $?
# }

# DOWNLOAD_AND_EXTRACT() {
#     echo -n "Downloading ${COMPONENT} Application File:"
#     curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
#     stat $?

#     echo "Cleanup of old ${COMPONENT} Files"
#     rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log
#     cd /home/${FUSER}

#     echo -n "Extracting ${COMPONENT} Files:"
#     unzip -o /tmp/${COMPONENT}.zip >> /tmp/${COMPONENT}.log
#     mv ${COMPONENT}-main ${COMPONENT}
#     stat $?

#     echo "Changing the Ownership to $FUSER"
#     chown -R $FUSER:$FUSER $COMPONENT/
#     cd /home/${FUSER}/${COMPONENT}
# }

# CONFIG_SVC() {
# echo -n "Configuring the System File:"
# sed -i -e 's/MONGO_DNSNAME/mongodb.awsdevops.internal/' -e 's/MONGO_ENDPOINT/mongodb.awsdevops.internal/' -e 's/REDIS_ENDPOINT/redis.awsdevops.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.awsdevops.internal/' -e 's/CARTENDPOINT/cart.awsdevops.internal/' -e 's/DBHOST/mysql.awsdevops.internal/'  /home/${FUSER}/${COMPONENT}/systemd.service
# mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
# stat $?

# echo -n "Starting the $COMPONENT Service:"
# systemctl daemon-reload &>> /tmp/${COMPONENT}.log
# systemctl enable ${COMPONENT} &>> /tmp/${COMPONENT}.log
# systemctl start ${COMPONENT} &>> /tmp/${COMPONENT}.log
# stat $?
# }

# # NordeJS Installiation
# NORDEJS() {
#     echo -n "Configureing yum repo for NodeJS:"
#     curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - >> /tmp/${COMPONENT}.log
#     stat $?

#     echo -n "Installing NodeJS:"
#     yum install nodejs -y &>> /tmp/${COMPONENT}.log
#     stat $?

#     #calling user creation function
#     USER_SETUP

#     #Calling DOWNLOAD_AND_EXTRACT function
#     DOWNLOAD_AND_EXTRACT

#     echo -n "Installing ${COMPONENT} Dependencies:"
#     npm install &>> /tmp/${COMPONENT}.log
#     stat $?

#     #Calling configuration function
#     CONFIG_SVC
# }

# MAVEN () {
#     echo -n "Instaling Maven: "
#     yum install maven -y &>> LOGFILE  # installs maven with java 8
#     stat $?

#     USER_SETUP

#     DOWNLOAD_AND_EXTRACT

#     echo -n "Generating the artifact: "
#     cd /home/${FUSER}/${COMPONENT}
#     mvn clean package &>> LOGFILE
#     mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar
#     stat $?

#     CONFIG_SVC

# }

# PYTHON() {
#     echo -n "Installing Pyhton:"
#     yum install python36 gcc python3-devel -y &>> ${LOGFILE} 
#     stat $? 

#     USER_SETUP

#     DOWNLOAD_AND_EXTRACT

#     cd /home/${FUSER}/${COMPONENT}/
#     pip3 install -r requirements.txt   &>> ${LOGFILE} 
#     stat $? 

#     USER_ID=$(id -u roboshop)
#     GROUP_ID=$(id -g roboshop)

#     echo -n "Updating the $COMPONENT.ini file"
#     sed -i -e "/^uid/ c uid=${USER_ID}" -e "/^gid/ c gid=${GROUP_ID}" payment.ini
#     stat $? 

#     CONFIG_SVC
# }