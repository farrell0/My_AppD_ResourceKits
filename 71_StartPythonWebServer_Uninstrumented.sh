#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to start our Python Application Web server.
#  (Uninstrumented; no appD)
#


#  Import settings from file, ./04*
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
   echo "   to see which IP address we want to operate the Python Application"
   echo "   Web Server on."
   echo ""
   echo ""
   echo "   Currently, you are on the wrong box."
   echo ""
   echo "   If this notice is in error, you must edit the 04* file to proceed."
   echo ""
   echo ""
   exit 2
}


###################################################


echo ""
echo ""
echo "This program will start the Python Application Web Server."
echo "   (In an uninstrumented manner.)"
echo ""
echo "This program will run in the foreground, with diagnostic"
echo "output occasionally sent to the screen."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################
###################################################


#  We cd below.
#  And, this program terminates on interrupt.
#
#  Set it up so we return to the original directory
#  when that occurs.
#

l_pwd=`pwd`

on_interrupt() {
   echo "[INTERRUPT RECEIVED.]"
   echo ""
   cd "${l_pwd}"
}

trap 'on_interrupt' INT


###################################################
###################################################


#  Run the Python Application Web server in the
#  foreground.
#

cd "./P0_PythonApps/60_PythonWebServer"
   #
python3 ./60_index.py





