#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release


#  Program that does a (ps -ef) to look for any 
#  running MongoDB daemons/other.
#
echo ""
echo ""
echo "Programs running with 'mongo' in their name-"
echo ""

ps -ef | egrep "^UID|mongod" | grep -v "grep" 

echo ""
echo ""


