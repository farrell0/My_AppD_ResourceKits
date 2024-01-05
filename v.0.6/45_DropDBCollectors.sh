#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will delete our previously created 
#  DB Agent Collectors.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


echo ""
echo ""
echo "This program deletes the AppD DB Agent Collectors for our"
echo "username."
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


#  First, get all collectors. Then we'll filter and delete.
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
   "id": .config.id
   }'`

[ -z "${l_all}" ] && {
   echo "INFO:  No AppD Collectors found for user (${MY_USERNAME})."
   echo ""
   echo "   Normal program shutdown."
   echo ""
   echo ""
   exit 0
} || {

   #  Our actual delete loop-
   #
   for l_each in ${l_all}
      do
      l_id=`echo "${l_each}" | jq -r ".id"`
         #
      l_response=`curl -s                                                                \
         -H "Accept: application/json"                                                   \
         --location -X DELETE                                                            \
         "https://${CONTROLLER_HOST_NAME}/controller/rest/databases/collectors/${l_id}"  \
         --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}" `
            #
      echo "   Deleting AppD Collector ID: $l_each}"
      #  
      #  There was no 'response' if no collector found for a given ID.
      #     (Nothing to output.)
      #
      done

}


echo ""
echo ""






