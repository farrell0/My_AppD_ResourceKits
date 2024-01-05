#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will list our AppD Application.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


#  For reference;  here is the raw data we get back from this,
#
#     { "name": "farrell-python-app", "description": "", "id": 6187,
#        "accountGuid": "4b609009-9f90-4e00-929c-b60e543167bd" }
#     


################################################


echo ""
echo ""
echo "This program will list our Application as returned from the"
echo "AppD Console REST API."
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
l_response=`curl -s                                                              \
   --header "Content-Type: application/json"                                     \
   --header "Accept: application/json"                                           \
   --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}"                    \
   --location -X GET                                                             \
   "https://${CONTROLLER_HOST_NAME}/controller/rest/applications?output=JSON" |  \
   jq '.[] | select(.name == "${MY_APPNAME}")' `


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


l_name=`       echo "${l_response}" | jq -r ".name"`
l_description=`echo "${l_response}" | jq -r ".description"`
l_accountGuid=`echo "${l_response}" | jq -r ".accountGuid"`
l_id=`         echo "${l_response}" | jq -r ".id"`

echo   "Our Application as returned from the AppD Console:"
printf "   %-18s\n" "${l_name}" 
printf "   %-18s\n" "${l_id}" 
printf "   %-18s\n" "${l_accountGuid}" 
printf "   %-18s\n" "${l_description}" 

echo ""
echo ""






