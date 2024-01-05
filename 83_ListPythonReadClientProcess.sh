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
[ "${PRC_IP}" != "${MY_IP}" ] && {
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
   echo "   to see which IP address we want to list the Python"
   echo "   Application Read Client on, and also which IP this"
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
echo "Listing the Python Application Read Client processes:"
echo ""
echo ""
l_pid=`ps -ef | egrep "python3|pyagent" | grep "PythonReadClient" | awk '{print $2}'`
ps -f -p `echo "${l_pid}" | awk '{print$1}'`

echo ""
echo ""



