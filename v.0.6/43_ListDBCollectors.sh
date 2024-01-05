#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will list our DB Agent Collectors.
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
#     {
#     "performanceState":null,
#     "collectorStatus":"ERROR",
#     "eventSummary":null,
#     "configId":40,
#     "nodeId":51549,
#     "config":
#        {
#        "id":40,
#        "version":0,
#        "name":"ECommerce-Eli-Oracle",
#        "nameUnique":true,
#        "builtIn":false,
#        "createdBy":null,
#        "createdOn":1629679979000,
#        "modifiedBy":null,
#        "modifiedOn":1629682230000,
#        "type":"ORACLE",
#        "hostname":"oracle-db",
#        "useWindowsAuth":false,
#        "username":"system",
#        "password":"appdynamics_redacted_password",
#        "port":1521,
#        "loggingEnabled":false,
#        "enabled":true,
#        "excludedSchemas":null,
#        "jdbcConnectionProperties":[],
#        "databaseName":"",
#        "failoverPartner":null,
#        "connectAsSysdba":false,
#        "useServiceName":false,
#        "sid":"XE",
#        "customConnectionString":null,
#        "enterpriseDB":false,
#        "useSSL":false,
#        "enableOSMonitor":false,
#        "hostOS":null,
#        "useLocalWMI":false,
#        "hostDomain":null,
#        "hostUsername":null,
#        "hostPassword":null,
#        "dbInstanceIdentifier":null,
#        "region":null,
#        "certificateAuth":false,
#        "removeLiterals":true,
#        "sshPort":0,
#        "agentName":"ECommerce-dbagent",
#        "dbCyberArkEnabled":false,
#        "dbCyberArkApplication":null,
#        "dbCyberArkSafe":null,
#        "dbCyberArkFolder":null,
#        "dbCyberArkObject":null,
#        "hwCyberArkEnabled":false,
#        "hwCyberArkApplication":null,
#        "hwCyberArkSafe":null,
#        "hwCyberArkFolder":null,
#        "hwCyberArkObject":null,
#        "orapkiSslEnabled":false,
#        "orasslClientAuthEnabled":false,
#        "orasslTruststoreLoc":null,
#        "orasslTruststoreType":null,
#        "orasslTruststorePassword":null,
#        "orasslKeystoreLoc":null,
#        "orasslKeystoreType":null,
#        "orasslKeystorePassword":null,
#        "ldapEnabled":false,
#        "customMetrics":null,
#        "dbCustomEvents":null,
#        "subConfigs":[], 
#        "jmxPort":0,
#        "backendIds":[],
#        "extraProperties":[]
#        },
#        "licensesUsed":-1
#     },
#        ...  ]
#     

#  Sample output,
#
#     This program will list the AppD DB Agent Collectors for our
#     username.
#     
#     Additionally; this program serves to validate our AppD
#     Administrator rights Auth-token generated in the Controller.
#     
#     
#     Collector Status   Id       Collector Name                   Port   DB-Type    DB Hostname      DB Username      DB Agent Name        OSMoni HostOS SSH Port Host Username
#     ================== ======== ================================ ====== ========== ================ ================ ==================== ====== ====== ======== =============
#     COLLECTING_DATA    414      farrell-dbagent01-collector      27017  MONGO      192.168.182.20   null             farrell-dbagent01    false  null   0        null             
#     COLLECTING_DATA    415      farrell-dbagent02-collector      27017  MONGO      192.168.182.21   null             farrell-dbagent02    true   LINUX  22       root 
#


################################################


echo ""
echo ""
echo "This program will list the AppD DB Agent Collectors for our"
echo "username."
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
l_response=`curl -s                                                        \
   -H "Accept: application/json"                                           \
   --location -X GET                                                       \
   "https://${CONTROLLER_HOST_NAME}/controller/rest/databases/collectors"  \
   --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}" `


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


#  Filtering, and formatting output
#
#  .  The tr(C) below; some of the data had new lines embedded
#     within them, messing up output.
#
l_all=`echo "${l_response}" | tr -d '\n\t\r ' | jq -c -r ' .[] |
   select(.config.name | 
   startswith("'${MY_USERNAME}'")) | {
   "collectorstatus": .collectorStatus,
   "name":            .config.name,
   "password":        .config.password, 
   "port":            .config.port,
   "type":            .config.type, 
   "hostname":        .config.hostname,
   "username":        .config.username,
   "agentname":       .config.agentName,

   "enableosmonitor": .config.enableOSMonitor,
   "hostos":          .config.hostOS,
   "sshport":         .config.sshPort,
   "hostusername":    .config.hostUsername,

   "id":              .config.id
   }'`

echo -n "Collector Status   Id      "
echo -n " Collector Name                  "
echo -n " Port   DB-Type    DB Hostname     "
echo -n " DB Username      DB Agent Name       "
echo    " OSMoni HostOS SSH Port Host Username"
   #
echo -n "================== ========"
echo -n " ================================"
echo -n " ====== ========== ================"
echo -n " ================ ===================="
echo    " ====== ====== ======== ============="

for l_each in ${l_all}
   do
   l_collectorstatus=` echo "${l_each}" | jq -r ".collectorstatus"`
   l_id=`              echo "${l_each}" | jq -r ".id"             `
   l_name=`            echo "${l_each}" | jq -r ".name"           `
   l_port=`            echo "${l_each}" | jq -r ".port"           `
   l_type=`            echo "${l_each}" | jq -r ".type"           `
   l_hostname=`        echo "${l_each}" | jq -r ".hostname"       `
   l_username=`        echo "${l_each}" | jq -r ".username"       `
   l_agentname=`       echo "${l_each}" | jq -r ".agentname"      `

   l_enableosmonitor=` echo "${l_each}" | jq -r ".enableosmonitor"`
   l_hostos=`          echo "${l_each}" | jq -r ".hostos"         `
   l_sshport=`         echo "${l_each}" | jq -r ".sshport"        `
   l_hostusername=`    echo "${l_each}" | jq -r ".hostusername"   `

   printf "%-18s %-8s %-32s %-6s %-10s %-16s %-16s %-20s %-6s %-6s %-8s %-16s \n" \
      "${l_collectorstatus}" "${l_id}" "${l_name}"  "${l_port}"   \
      "${l_type}" "${l_hostname}" "${l_username}"                 \
      "${l_agentname}" "${l_enableosmonitor}" "${l_hostos}"       \
      "${l_sshport}" "${l_hostusername}"

   done

echo ""
echo ""






