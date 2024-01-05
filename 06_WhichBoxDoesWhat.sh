#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to output simple overview.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


###################################################
###################################################


echo ""
echo ""
echo "Which box does what-"
echo ""
echo "   .  192.168.182.20  ::  Is a MongoDB server, part of a 2 node MDB Replica Set."
echo "   .  192.168.182.21  ::  Is a MongoDB server, part of a 2 node MDB Replica Set."
echo "         You can bulk load data from whichever box above is 'primary'."
echo ""
echo "   .  192.168.182.22  ::  Hosts our AppD DB Agents."
echo "         These AppD agents run SSH(C) for hardware monitoring into the MDB boxes."
echo ""
echo "   .  192.168.182.23  ::  Hosts our Python App Web Server."
echo "   .  192.168.182.24  ::  Hosts our Python App Web Client, a reader."
echo "   .  192.168.182.25  ::  Hosts our Python App Web Client, a writer."
echo "         There are AppD Hardware Agents on each of the 3 boxes above."
echo "         The Web Browser app (when running), is at,"
echo "            http://${MY_PYTHON_WEBSERVER_IP}:${MY_PYTHON_WEBSERVER_PORT}"
echo ""
echo "   .  The currently targeted AppD Controller is at,"
echo "         https://${CONTROLLER_HOST_NAME}/controller"
echo "         Accountname/Username:  ${APPDYNAMICS_AGENT_ACCOUNT_NAME}"
echo ""
echo ""
echo "   .  You are currently on box,"
echo "         ${MY_IP}"
echo ""
echo ""







