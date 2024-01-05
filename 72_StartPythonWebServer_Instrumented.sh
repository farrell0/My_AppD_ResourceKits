#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to start our Python Application Web server.
#  (Instrumented; with AppD)
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
###################################################


#  Maintain our application log files.
#
l_logfile1="${PARENT_DIR}/S1_PythonWebServer.stdout.log"
l_logfile2="${PARENT_DIR}/S2_PythonWebServer.stderr.log"
l_logfile3="${PARENT_DIR}/S3_PythonWebServer.app.log"
   #
rm -fr    "${l_logfile1}" "${l_logfile2}" "${l_logfile3}"
touch     "${l_logfile1}" "${l_logfile2}" "${l_logfile3}" 
chmod 777 "${l_logfile1}" "${l_logfile2}" "${l_logfile3}" 


echo ""
echo ""
echo "This program will start the Python Application Web Server."
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


#  We aren't using this anymore-
#
#  #  We cd below.
#  #  And, this program terminates on interrupt.
#  #
#  #  Set it up so we return to the original directory
#  #  when that occurs.
#  #
#  
#  l_pwd=`pwd`
#  
#  on_interrupt() {
#     echo "[INTERRUPT RECEIVED.]"
#     echo ""
#     cd "${l_pwd}"
#  }
#  
#  trap 'on_interrupt' INT


on_interrupt() {
   echo "[INTERRUPT RECEIVED.]"
   echo ""
   echo "INFO:  You were in a (tail -f)."
   echo ""
   echo "   The Python Web Application server is still running."
   echo "   You can stop it by running file, 74*"
   echo ""
}

trap 'on_interrupt' INT


###################################################
###################################################


#  Run the Python Application Web server in the
#  background.
#

#  Relative/absolute pathnames to JS and CSS files;
#  as the application is written currently, we
#  must cd into the app's home directory in order
#  to launch.
#
cd "./P0_PythonApps/60_PythonWebServer"
   #
(>&1 ; pyagent run -c ../../C2_PythonAgent_PythonWebServer.se-lab.cfg  \
   -- python3 ./60_index.py --logfile "${l_logfile3}")                 \
   >> "${l_logfile1}" 2>> "${l_logfile2}"  &

echo ""
echo ""
echo "INFO: Python Application Web server launched with PID, ${!}"
echo ""
echo "   If you wish to stop this program, you can use file:  74*"
echo ""
echo ""


#  Give the app time to come up.
#
sleep 10
   #
tail -f "${l_logfile3}"







