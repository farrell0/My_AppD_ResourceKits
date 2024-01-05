#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to output AppD Controller info
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


###################################################
###################################################


echo ""
echo ""
echo "AppD Controller pointed to from file 04*:"
echo ""
echo "   https://${CONTROLLER_HOST_NAME}/controller"
echo "   Accountname/Username:  ${APPDYNAMICS_AGENT_ACCOUNT_NAME}"
echo ""
echo ""









