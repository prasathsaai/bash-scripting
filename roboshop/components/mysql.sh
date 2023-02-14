#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=mysql
LOGFILE=robot.log
MYSQL_PASSWORD=RoboShop@1

echo -n "Configuring the ${COMPONENT} repo: "
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

# Installing MySQL
echo -n "Installing ${COMPONENT} Server: "
yum install mysql-community-server -y &>> ${LOGFILE}
stat $?

echo -n "Starting ${COMPONENT} Service: "
systemctl enable mysqld &>> ${LOGFILE}
systemctl start mysqld &>> ${LOGFILE}
stat $?

echo -n "Fletching the default root password: "
DEFAULT_ROOT_PASSWORD=$( sudo grep temp /var/log/mysqld.log | head -n 1 | awk -F " " '{print $NF}')
stat $?

# echo -n "Uninstalling the password validation : "
# echo 'uninstall plugin validate_password;' > /tmp/passward-validate.sql
# mysql --connect-expired-password  -uroot -p RoboShop1 < /tmp/password-validate.sql
echo -n "Changing the root password"
echo 'show databases;' | mysql -uroot -pRoboShop@1 &>> ${LOGFILE}
if [ $? -ne 0 ]; then
    echo -n "Reset the password: "
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password  -uroot -p"${DEFAULT_ROOT_PASSWORD}" &>> ${LOGFILE}
    stat $?
fi

echo 'show plugins;' | mysql -uroot -pRoboShop@1 &>> ${LOGFILE} | grep validate_password &>> ${LOGFILE}
if [ $? -eq 0 ] ; then
    echo -n "Uninstall the password validate plugin: "
    echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1 &>> ${LOGFILE}
    stat $?
fi
