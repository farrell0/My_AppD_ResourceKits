#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release


echo ""
echo ""
echo "This program will list the active AppD DB Agents."
echo ""
echo ""


###################################################


#  Since we do an interupt, versus quit, we'll sleep
#  a bit after the call to terminate.
#
ps -ef | egrep "^UID|dbagent" | grep -v "grep"

echo ""
echo ""


