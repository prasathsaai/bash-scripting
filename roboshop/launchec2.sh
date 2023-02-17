#!/bin/bash

if [ -z "$1" ] ; then
    echo -e "\e[31m Machine Name IS Missing \e[0m"
    exit 1
fi

COMPONENT=$1
#AMI_ID="ami-0c1d144c8fdd8d690"
AMI_ID=$(aws ec2 describe-images --filter "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID="sg-09bb8bda000eb1add"
echo "The AMI which we are using is: $AMI_ID"

aws ec2 run-instance --image-id #{AMI_ID} --instance-type t3.medium --security-group-ids $(SGID) --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq

echo 