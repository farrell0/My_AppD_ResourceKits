#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to install and start two AppDynamics DB
#  agents against two expected MongoDB hosts; a
#  primary and a replica.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


###################################################
###################################################


#  Check to see which host we are on-
#
[ "${DBAGENT_IP}" != "${MY_IP}" ] && {
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
   echo "   to see which IP address we want install/start DB Agents"
   echo "   on, and also which IP this program is executing on."
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
echo "This program will perform all steps necessary to install and"
echo "start the AppD DB Agents."
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
[ ! -f "${DBAGENT_DIR}/start-dbagent" ] && {
   l_pwd=`pwd`
      #
   echo "DB Agent binaries not present as expected: installing from local copy now ..."
   echo ""
      #
   mkdir -p        "${DBAGENT_DIR}"
   chmod -R   777  "${DBAGENT_DIR}"
      #
   cp "${l_pwd}/S1_agents_softwareonly/20_db-agent-23.11.0.3556.zip" "${DBAGENT_DIR}"
      #
   cd              "${DBAGENT_DIR}"
      #
   unzip 20_db-agent-23.11.0.3556.zip  > /dev/null
   rm -f 20_db-agent-23.11.0.3556.zip
      #
   cd "${l_pwd}"
   echo ""
   echo ""
   }


###################################################


#  The AppD DB Agent is installed. 
#  Now, start two of these, one for each MongoDB host.
#
#  Note;
#
#     start-dbagent does an exec. So, to redirect the
#     stdout/stderr of that takes some unfamiliar code.
#
rm -fr "${DBAGENT_DIR}/DBAgent.[1-2].log"

echo "Starting AppD DB Agent #1 (designated for MongoDB node-1) ..."
echo "   (stdout/stderr directed to:  ${DBAGENT_DIR}/DBAgent.1.log)"
   #
(>&1 ; "${DBAGENT_DIR}/start-dbagent" -Xms512M -Xmx1G                               \
   -Ddbagent.name="${MY_USERNAME}-dbagent01"                                        \
   -Dappydynamics.agent.uniqueHostId="${MY_USERNAME}-host22"                        \
   -Dappdynamics.controller.hostName="se-lab.saas.appdynamics.com"                  \
   -Dappdynamics.controller.ssl.enabled="true"                                      \
   -Dappdynamics.controller.port=443                                                \
   -Dappdynamics.agent.accountAccessKey="${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY}"   \
   -Dappdynamics.agent.accountName="se-lab") > "${DBAGENT_DIR}/DBAgent.1.log"       \
   2> /dev/null &

#  Just to be safe
#
sleep 4

echo ""
echo ""
echo "Starting AppD DB Agent #2 (designated for MongoDB node-2) ..."
echo "   (stdout/stderr directed to:  ${DBAGENT_DIR}/DBAgent.2.log)"
   #
(>&1 ; "${DBAGENT_DIR}/start-dbagent" -Xms512M -Xmx1G                               \
   -Ddbagent.name="${MY_USERNAME}-dbagent02"                                        \
   -Dappydynamics.agent.uniqueHostId="${MY_USERNAME}-host22"                        \
   -Dappdynamics.controller.hostName="se-lab.saas.appdynamics.com"                  \
   -Dappdynamics.controller.ssl.enabled="true"                                      \
   -Dappdynamics.controller.port=443                                                \
   -Dappdynamics.agent.accountAccessKey="${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY}"   \
   -Dappdynamics.agent.accountName="se-lab") > "${DBAGENT_DIR}/DBAgent.2.log"       \
   2> /dev/null &


###################################################
###################################################


echo ""
echo ""
echo "Next Steps:"
echo ""
echo "   .  The AppD DB Agents are installed/started."
echo "      Now, define the 'Collectors' within the AppD Console."
echo ""
echo "   .  Drive traffic against MongoDB."
echo ""
echo "   .  Goto the AppD Controller,"
echo ""
echo "         https://${CONTROLLER_HOST_NAME}/controller"
echo "         Accountname/Username:  ${APPDYNAMICS_AGENT_ACCOUNT_NAME}"
echo ""
echo ""







