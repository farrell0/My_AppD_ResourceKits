#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release


#  Program to stop the Python Application Web server.
#

. ./04_ImportSettings.sh


###################################################
###################################################


#  Check to see which host we are on-
#
[ "${MY_PYTHON_WEBSERVER_IP}" != "${MY_IP}" ] && {
   #
   #  We are not on a host we want to do this work
   #  on. We will terminate this program.
   #
   echo ""
   echo ""
   echo "ERROR:  This program reads the file titled,"
   echo ""
   echo "      04_ImportSettings.sh"
   echo ""
   echo "   to see which IP address we want to stop the Python"
   echo "   Application Web server on, and also which IP this"
   echo "   program is executing on."
   echo ""
   echo "   Currently, you are on the wrong box."
   echo ""
   echo "   If this notice is in error, you must edit the 04* file to proceed."
   echo ""
   echo ""
   exit 2
}


###################################################
###################################################


echo ""
echo ""
echo "This program will soft kill the Python Application Web server."
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
#  Find the process that uses the port.
#
l_pid=$(lsof -t -i:"${MY_PYTHON_WEBSERVER_PORT}")
kill -15 "${l_pid}" 2> /dev/null
   #
sleep 10


echo "Python Application Web server stopped."
echo ""
echo ""


