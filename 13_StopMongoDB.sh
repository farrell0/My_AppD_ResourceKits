#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release


echo ""
echo ""
echo "This program will soft kill the MongoDB database."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################


#  Since we do an interupt, versus quit, we'll sleep
#  a bit after the call to terminate.
#
l_pid=`ps -ef | grep mongod | grep -v "grep" | awk '{print $2}'`
kill -15 "${l_pid}" 2> /dev/null
   #
sleep 10




