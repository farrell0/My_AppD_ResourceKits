#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will create our necessary AppD DB Collectors.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


echo ""
echo ""
echo "This program creates the necessary AppD DB Collectors."
echo ""
echo ""
echo "   ** Our Auth-token was created on: ${MY_APPD_ADMINAUTHTOKEN_DATE}"
echo "      The longest Auth-tokens may be valid for is 30 days."
echo ""
echo "For at least some of the nodes, ssh(C) needs to be enabled"
echo "for the root user."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################
###################################################


#  Because we do this (n) times, put it in a function.
#
function f1(){

   #  The actual Curl command-
   #
   l_data=${1}
      #
   l_response=`curl -s                                                               \
      --header "Content-Type: application/json"                                      \
      --header "Accept: application/json"                                            \
      --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}"                     \
      --location -X POST                                                             \
      "https://${CONTROLLER_HOST_NAME}/controller/rest/databases/collectors/create"  \
      --data "${l_data}" `
   
   #  Checking the response to the above.
   #
   l_permserror="HTTP Error 401 Unauthorized"
      #
   if [[ "${l_response}" = *"${l_permserror}"* ]] 
      then
      echo "ERROR:  Our Curl(C) into the AppD Controller returned a -401 error."
      echo ""
      echo "   The most likely cause is an expired AppD Admin Auth-token."
      echo ""
      echo ""
      exit 2
   fi

}


###################################################
###################################################


#  Populate the message body (data), then POST.
#
#  We hard code the DB Agent name.
#
l_data="""
   {
   \"type\":\"MONGO\",
   \"name\":\"${MY_USERNAME}-dbagent01-collector\",
   \"hostname\":\"${MDB_IPS[0]}\",
   \"port\":${MDB_PORT},
   \"enabled\":true,
   \"agentName\":\"${MY_USERNAME}-dbagent01\",

   \"enableOSMonitor\":true,
   \"hostOS\":\"LINUX\",
   \"sshPort\":22,
   \"hostUsername\":\"root\",
   \"hostPassword\":\"password\",

   \"username\":null,
   \"password\":null,
   \"useServiceName\":false,
   \"useSSL\":false,
   \"hostDomain\":null,
   \"dbInstanceIdentifier\":null,
   \"certificateAuth\":false,
   \"ldapEnabled\":false
   }
   """
      #
f1 "${l_data}"
   #
echo "Created Collector: ${MY_USERNAME}-dbagent01-collector"


l_data="""
   {
   \"type\":\"MONGO\",
   \"name\":\"${MY_USERNAME}-dbagent02-collector\",
   \"hostname\":\"${MDB_IPS[1]}\",
   \"port\":${MDB_PORT},
   \"enabled\":true,
   \"agentName\":\"${MY_USERNAME}-dbagent02\",

   \"enableOSMonitor\":true,
   \"hostOS\":\"LINUX\",
   \"sshPort\":22,
   \"hostUsername\":\"root\",
   \"hostPassword\":\"password\",

   \"username\":null,
   \"password\":null,
   \"useServiceName\":false,
   \"useSSL\":false,
   \"hostDomain\":null,
   \"dbInstanceIdentifier\":null,
   \"certificateAuth\":false,
   \"ldapEnabled\":false
   }
   """
      #
f1 "${l_data}"
   #
echo "Created Collector: ${MY_USERNAME}-dbagent02-collector"


echo ""
echo ""


