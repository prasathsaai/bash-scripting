#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=user

NODEJS # Calling nordejs function

echo "****----${COMPONENT} Service Sucessfully Started----****"

