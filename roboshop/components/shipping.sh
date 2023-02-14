#!/bin/bash

set -e # ensure your script will stop at faillur command

source components/common.sh  # Validating the excuting user is root or not 

echo ">>> /e[43;36m Installing Shipping /e[0m <<<"

COMPONENT=shipping

MAVEN