#!/bin/bash
set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not

COMPONENT=cart

echo -e ">>> \e[41;36m Installing Cart \e[0m <<<"

NORDEJS # Calling nordejs function

echo "****----${COMPONENT} Service Sucessfully Started----****"