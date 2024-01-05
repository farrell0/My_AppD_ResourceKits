#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to start our Python Web Application Read Client.
#  (Instrumented; with appD)
#


#  Import settings from file, ./04*
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
   echo "   to see which IP address we want to operate the Python Web Application"
   echo "   Read Client on."
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


#  Maintain our application log files.
#
l_logfile1="${PARENT_DIR}/R1_PythonReadClient.stdout.log"
l_logfile2="${PARENT_DIR}/R2_PythonReadClient.stderr.log"
l_logfile3="${PARENT_DIR}/R3_PythonReadClient.app.log"
   #
rm -fr    "${l_logfile1}" "${l_logfile2}" "${l_logfile3}"
touch     "${l_logfile1}" "${l_logfile2}" "${l_logfile3}" 
chmod 777 "${l_logfile1}" "${l_logfile2}" "${l_logfile3}" 


echo ""
echo ""
echo "This program will start the Python Web Application Read Client."
echo "   (In an AppD instrumented manner.)"
echo ""
echo "This program will run in the background, with diagnostic"
echo "output occasionally sent to 3 logfiles."
echo ""
echo "Those logfiles are:"
echo "   ${l_logfile1}"
echo "   ${l_logfile2}"
echo "   ${l_logfile3}"
echo ""
echo "You will be put in a (tail -f) of the 3rd logfile."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################
###################################################


#  This program terminates on interrupt.
#

on_interrupt() {
   echo "[INTERRUPT RECEIVED.]"
   echo ""
   echo "INFO:  You were in a (tail -f)."
   echo ""
   echo "   The Python Application Read Client is still running."
   echo "   You can stop it by running file, 84*"
   echo ""
}

trap 'on_interrupt' INT


###################################################
###################################################


#  Run the Python Web Application Read Client in
#  the background.
#

cd "./P0_PythonApps/61_PythonWebClient_Reader"
   #

(>&1 ; pyagent run -c ../../C5_PythonAgent_PythonReadClient.se-lab.cfg   \
   -- python3 ./61_PythonWebClient_Reader.py --logfile "${l_logfile3}")  \
   >> "${l_logfile1}" 2>> "${l_logfile2}"  &

echo ""
echo ""
echo "INFO: Python Application Read Client launched with PID, ${!}"
echo ""
echo "   If you wish to stop this program, you can use file:  84*"
echo ""
echo ""

#  Give the app time to come up.
#
sleep 10
   #
tail -f "${l_logfile3}"








