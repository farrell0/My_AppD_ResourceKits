#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will delete our Machine Agents.
#
#  It also serves to validate our AppD Auth-token.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


echo ""
echo ""
echo "This program will delete the AppD Machine Agents for our"
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
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


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


echo "${l_response}" | jq -c '.[]' | while read l_each
   do

   l_id=$(       echo "${l_each}" | jq -r ".id")
      #

   #  Unfinished-
   #
   #  Did delete something.
   #  Wasn't certain what this actually deleted.
   #

   #  l_response=`curl -s                                                                                  \
   #     --header "Content-Type: application/json"                                                         \
   #     --header "Accept: application/json"                                                               \
   #     --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}"                                        \
   #     --location -X DELETE                                                                              \
   #     "https://${CONTROLLER_HOST_NAME}/controller/rest/applications/${MY_APPNAME}/nodes/?${l_id}"    `
 
   echo "AppD Node ID deleted: ${l_id}"

   done

echo ""
echo ""








