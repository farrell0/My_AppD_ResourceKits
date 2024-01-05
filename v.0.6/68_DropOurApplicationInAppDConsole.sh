#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will delete our App in the AppD Console.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


echo ""
echo ""
echo "This program will delete our Application in the AppD Console"
echo "with the application name.  (${MY_APPNAME})"
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


#  Data from the call below-
#
#     { "name": "farrell-python-app", "description": "", "id": 6187,
#        "accountGuid": "4b609009-9f90-4e00-929c-b60e543167bd" }
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


#  Further checking the response from above.
#
l_length=${#l_response}
   #
[ $l_length -lt 1 ] && {
   echo "WARN:  The AppD Console Application named  (${MY_APPNAME})  doesn't exist."
   echo ""
   echo "There is nothing to delete."
   echo ""
   echo ""
      #
   exit 2
}


###################################################
###################################################


#  Appears to work, but .. .. App still appears in the 
#  AppD Console, versus when you delete is in the Console
#  itself.
#
l_id=` echo "${l_response}" | jq -r ".id"`
l_response=`curl -s                                                                                    \
   --header "Content-Type: application/json"                                                           \
   --header "Accept: application/json"                                                                 \
   --header "Authorization: Bearer ${MY_APPD_ADMINAUTHTOKEN}"                                          \
   --location -X DELETE                                                                                \
   "https://${CONTROLLER_HOST_NAME}/controller/restui/applicationManager/deleteApplication/${l_id}"  `


echo "Our Application in AppD Console deleted:  (${MY_APPNAME})"
echo ""
echo ""
















