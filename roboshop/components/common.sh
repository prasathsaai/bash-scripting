#!/bin/bash

# Validating the excuting user is root or not

ID = $(id -u)
if [ $ID -ne 0 ]; then
    echo -e "\e[31m Try executing scripts with SUDO or ROOT user \e[0m"
    exit 1
fi