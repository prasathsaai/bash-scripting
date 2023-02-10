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
