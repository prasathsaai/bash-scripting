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

PRIVATE_IP=$(aws ec2 run-instances --image-id ${AMI_ID} --instance-type t3.medium --security-group-ids ${SGID} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" --instance-market-options "MarketType=spot, SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

echo "PrivateIP Address of the created $COMPONENT : ${PRIVATE_IP}"

echo "Spot Instance $COMPONENT is Ready"

echo "Create Route53 Record for $COMPONENT"

sed -e "s/PRIVATEIP/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" r53.json  >/tmp/record.json
aws route53 change-resource-record-sets --hosted-zone-id Z091363010ZE5GYT34KFB --change-batch file://tmp/record.json | jq
