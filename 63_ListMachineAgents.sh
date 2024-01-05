#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will list our Machine Agents.
#
#  It also serves to validate our AppD Auth-token.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


#  For reference;  here is the raw data we get back from this,
#
#     [ 
#     { "appAgentVersion": "Python Agent v23.10.0.6327 (proxy v23.10.0.35234)
#          compatible with 4.5.0.21130 Python Version 3.10.12",
#     "machineAgentVersion": "Machine Agent v23.11.0.3839 GA compatible
#          with 4.4.1.0 Build Date 2023-11-21 08:55:18",
#     "agentType": "PYTHON_APP_AGENT",
#     "type": "Other",
#     "machineName": "farrell-host23",
#     "appAgentPresent": true,
#     "nodeUniqueLocalId": "",
#     "machineId": 853530,
#     "machineOSType": "Linux",
#     "tierId": 24018,
#     "tierName": "farrell-tier-webserver",
#     "machineAgentPresent": true,
#     "name": "farrell-node-23",
#     "ipAddresses": null,
#     "id": 1409806
#     },
#        ...  ]
#     

#  Sample output,
#
#                                   Applic    Machine
#                                   Agent     Agent
#     Agent Type          OS Type   Present   Present   Host Name                 Node Name                 Tier Name                       Machine Id   Tier Id      Id
#     ==================  ========  ========  ========  ========================  ========================  ==============================  ============ ============ ============
#     MACHINE_AGENT       Linux     false     true      farrell-host24            farrell-node-24           farrell-tier-readclient         854957       24048        1411330     
#     PYTHON_APP_AGENT    Linux     true      true      farrell-host23            node 7786                 farrell-tier-23                 854953       24049        1411331     
#     MACHINE_AGENT       Linux     false     true      farrell-host25            farrell-node-25           farrell-tier-writeclient        854958       24050        1411333  


################################################


echo ""
echo ""
echo "This program will list the AppD Machine Agents for our"
echo "application name.  (${MY_APPNAME})"
echo ""
echo "Additionally; this program serves to validate our AppD"
echo "Administrator rights Auth-token generated in the Controller."
echo ""
echo ""
echo "   ** Our Auth-token was created on: ${MY_APPD_ADMINAUTHTOKEN_DATE}"
echo "      The longest Auth-tokens may be valid for is 30 days."
echo ""
echo ""


###################################################
###################################################


#  So, curl(C) ..
#
#  .  Is a common tool; likely to be available, easy to
#     use.
#
#  .  Has limitations-
#
#     For example, you can not get the response header in
#     the JSON data out of the box.
#

#  -s      Supresses progress info
#  -H ..   Get a response in JSON
#  (GET)   Is the expected fetch method per AppD
#
#  Get all Applications,
#     https://${CONTROLLER_HOST_NAME}/controller/rest/applications
#
#  Get all collectors,
#     https://${CONTROLLER_HOST_NAME}/controller/rest/databases/collectors
#
l_response=`curl -s                                                                                  \
   --header "Content-Type: application/json"                                                         \
   --header "Accept: application/json"                                                               \
   --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}"                                        \
   --location -X GET                                                                                 \
   "https://${CONTROLLER_HOST_NAME}/controller/rest/applications/${MY_APPNAME}/nodes?output=JSON"  `


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


###################################################
###################################################


#  Filtering, and formatting output
#

echo    "                              Applic    Machine"
echo    "                              Agent     Agent"
echo -n "Agent Type          OS Type   Present   Present"
echo -n "   Host Name                 Node Name"
echo -n "                 Tier Name"
echo    "                       Machine Id   Tier Id      Id"
echo -n "==================  ========  ========  ========"
echo -n "  ========================"
echo -n "  ========================"
echo -n "  =============================="
echo    "  ============ ============ ============"

echo "${l_response}" | jq -c '.[]' | while read l_each
   do

   appAgentPresent=$(       echo "${l_each}" | jq -r ".appAgentPresent")
   l_agentType=$(           echo "${l_each}" | jq -r ".agentType")
   l_machineName=$(         echo "${l_each}" | jq -r ".machineName")
   l_appAgentPresent=$(     echo "${l_each}" | jq -r ".appAgentPresent")
   l_machineOSType=$(       echo "${l_each}" | jq -r ".machineOSType")
   l_tierName=$(            echo "${l_each}" | jq -r ".tierName")
   l_machineAgentPresent=$( echo "${l_each}" | jq -r ".machineAgentPresent")
   l_name=$(                echo "${l_each}" | jq -r ".name")
   l_machineId=$(           echo "${l_each}" | jq -r ".machineId")
   l_tierId=$(              echo "${l_each}" | jq -r ".tierId")
   l_id=$(                  echo "${l_each}" | jq -r ".id")
 
   printf "%-18s  %-8s  %-8s  %-8s  %-24s  %-24s  %-30s  %-12s %-12s %-12s\n" \
      "${l_agentType}" "${l_machineOSType}"               \
     "${l_appAgentPresent}" "${l_machineAgentPresent}"    \
      "${l_machineName}" "${l_name}" "${l_tierName}"      \
      "${l_machineId}" "${l_tierId}" "${l_id}" 

   done

echo ""
echo ""



