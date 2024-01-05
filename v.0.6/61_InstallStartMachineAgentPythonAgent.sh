#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to install and start the AppD Machine
#  Agent, and install the AppD Python Agent.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


###################################################
###################################################


#  Check to see which host we are on-
#
[ "${MY_PYTHON_WEBSERVER_IP}" != "${MY_IP}" ] && \
[ "${PRC_IP}" != "${MY_IP}" ] && [ "${PWC_IP}"   \
      != "${MY_IP}" ] && {
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
   echo "   to see which IP address we want install/start Appd"
   echo "   Machine Agents and Python Agents on, and also which"
   echo "   IP this program is executing on."
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
echo "This program will perform all steps necessary to install the"
echo "the AppD Machine Agent, and the AppD Python Agent."
echo ""
echo "And the AppD Machine Agent will be started in the foregound."
echo ""
echo "   (The AppD Python agent will be started when its"
echo "    accompanying program to monitor is started.)"
echo ""

if [ "${MY_IP}" == "${MY_PYTHON_WEBSERVER_IP}" ]; then
    echo "   You are on box: [ Python Application Web server tier ]"
elif [ "${MY_IP}" == "${PRC_IP}" ]; then
    echo "   You are on box: [ Python Read Client tier ]"
else
    echo "   You are on box: [ Python Write Client tier ]"
fi

echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################
###################################################


#  Check for the presence of a past installation.
#
[ ! -f "${MACHAGENT_DIR}/bin/machine-agent" ] && {
   l_pwd=`pwd`
      #
   echo "AppD Machine Agent binaries not present as expected... installing from local copy now ..."
      #
   mkdir -p        "${MACHAGENT_DIR}"
   chmod -R   777  "${MACHAGENT_DIR}"
      #
   cp "${l_pwd}/S1_agents_softwareonly/60_machineagent-bundle-64bit-linux-23.11.0.3839.zip" "${MACHAGENT_DIR}"
      #
   cd              "${MACHAGENT_DIR}"
      #
   unzip 60_machineagent-bundle-64bit-linux-23.11.0.3839.zip  > /dev/null
   rm -f 60_machineagent-bundle-64bit-linux-23.11.0.3839.zip
      #
   cd "${l_pwd}"
} || {
   echo "AppD Machine Agent binaries already installed......... no further work to do here ..."
}


#########################################
#########################################

#  This was my first attempt at an install path.
#
#  I stopped in favor on that further below.
#
#  [ ! -f "${PYTHONAGENT_DIR}/appdynamics-23.10.0.6327-py2.py3-none-any.whl" ] && {
#  
#        l_pwd=`pwd`
#        #
#     echo "AppD Python Agent binaries not present as expected.... installing from local copy now ..."
#        #
#     mkdir -p        "${PYTHONAGENT_DIR}"
#     chmod -R   777  "${PYTHONAGENT_DIR}"
#        #
#     cp "${l_pwd}/S1_agents_softwareonly/61_appdynamics-pythonagent-23.10.0.6327-linux-64bit.tar.bz2" "${PYTHONAGENT_DIR}"
#        #
#     cd              "${PYTHONAGENT_DIR}"
#        #
#     tar -xjf 61_appdynamics-pythonagent-23.10.0.6327-linux-64bit.tar.bz2  > /dev/null
#     rm -f    61_appdynamics-pythonagent-23.10.0.6327-linux-64bit.tar.bz2
#        #
#     #
#     #  This part needs more work.
#     #
#        #
#     cd "${l_pwd}"
#  } || {
#     echo "AppD Python Agent binaries already installed.......... no further work to do here ..."
#  }
#
#########################################
#########################################

#MMM

which pyagent >/dev/null 2>&1
   #
[ ${?} -eq 0 ] && {
   echo "AppD Python Agent binaries already installed.......... no further work to do here ..."
} || {
   echo "AppD Python Agent binaries not present as expected...  installing from local copy now ..."
   pip3 install -U appdynamics   2> /dev/null > /dev/null
}


###################################################
###################################################


#  The AppD Machine Agent is installed. 
#  Now, start it.
#

echo ""
echo "Starting AppD Machine agent in the foreground ..."
echo "   [ INTERRUPT ] to stop."
echo ""


#  **  Experimenting with over-riding JAVA_HOME-
#
#     Use ours, or the one that comes with the AppD
#     Machine Agent.
#
#     If present, it seems the AppD agent will use the 
#     bundled JRE.
#
#     """Using java executable at /opt/AD/60_MachAgent_Installed/jre/bin/java
#
#  export JAVA_HOME="${MACHAGENT_DIR/jre}"

#  Changing a Machine Agent into a Server Visibility
#  Agent-
#
#  At first we tried setting,
#
#     -Dappdynamics.agent.simd=true 
#
#  Which seemed to have no effect.
#


if [ "${MY_IP}" == "${MY_PYTHON_WEBSERVER_IP}" ]; then

   "${MACHAGENT_DIR}/bin/machine-agent"                                               \
      -Dappdynamics.controller.hostName="se-lab.saas.appdynamics.com"                 \
      -Dappdynamics.controller.port=443                                               \
      -Dappdynamics.controller.ssl.enabled=true                                       \
      -Dappdynamics.agent.accountAccessKey="${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY}"  \
      -Dappdynamics.agent.accountName="se-lab"                                        \
                                                                                      \
      -Dappdynamics.sim.enabled=true                                                  \
                                                                                      \
      -Dappdynamics.agent.applicationName="${MY_USERNAME}-python-app"                 \
      -Dappydynamics.agent.uniqueHostId="${MY_USERNAME}-host-23"                      \
      -Dappdynamics.agent.nodeName="${MY_USERNAME}-node-23"                           \
      -Dappdynamics.agent.tierName="${MY_USERNAME}-tier-webserver_ma"

elif [ "${MY_IP}" == "${PRC_IP}" ]; then

   "${MACHAGENT_DIR}/bin/machine-agent"                                               \
      -Dappdynamics.controller.hostName="se-lab.saas.appdynamics.com"                 \
      -Dappdynamics.controller.port=443                                               \
      -Dappdynamics.controller.ssl.enabled=true                                       \
      -Dappdynamics.agent.accountAccessKey="${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY}"  \
      -Dappdynamics.agent.accountName="se-lab"                                        \
                                                                                      \
      -Dappdynamics.sim.enabled=true                                                  \
                                                                                      \
      -Dappdynamics.agent.applicationName="${MY_USERNAME}-python-app"                 \
      -Dappydynamics.agent.uniqueHostId="${MY_USERNAME}-host-24"                      \
      -Dappdynamics.agent.nodeName="${MY_USERNAME}-node-24"                           \
      -Dappdynamics.agent.tierName="${MY_USERNAME}-tier-readclient_ma"

else

   "${MACHAGENT_DIR}/bin/machine-agent"                                               \
      -Dappdynamics.controller.hostName="se-lab.saas.appdynamics.com"                 \
      -Dappdynamics.controller.port=443                                               \
      -Dappdynamics.controller.ssl.enabled=true                                       \
      -Dappdynamics.agent.accountAccessKey="${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY}"  \
      -Dappdynamics.agent.accountName="se-lab"                                        \
                                                                                      \
      -Dappdynamics.sim.enabled=true                                                  \
                                                                                      \
      -Dappdynamics.agent.applicationName="${MY_USERNAME}-python-app"                 \
      -Dappydynamics.agent.uniqueHostId="${MY_USERNAME}-host-25"                      \
      -Dappdynamics.agent.nodeName="${MY_USERNAME}-node-25"                           \
      -Dappdynamics.agent.tierName="${MY_USERNAME}-tier-writeclient_ma"

fi


echo ""
echo ""







