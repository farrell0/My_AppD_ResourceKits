#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release


echo ""
echo ""
echo "This program will soft kill the AppD DB Agents."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################


#  Our kill loop.
#
for l_each in `ps -ef | grep dbagent | grep -v "grep" | awk '{print $2}'`
   do
   kill -15 ${l_each}  
   sleep 2
   done





