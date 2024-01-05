#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to create the MongoDB "monitor" user, as 
#  required by the AppD DB Agent.
#
#  We only allow running this program from a node
#  with MongoDB running on it.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


###################################################
###################################################


#  Check to see which host we are on-
#
l_flag=false

for l_each in ${MDB_IPS[@]}
   do
   [ "${l_each}" = "${MY_IP}" ] && l_flag=true
   done

[ ${l_flag} = false ] && {
   #
   #  We are not on a host we have MongoDB on. 
   #  We will terminate this program.
   #
   echo ""
   echo ""
   echo "ERROR:  This program reads the file titled,"
   echo ""
   echo "      04_ImportSettings.sh"
   echo ""
   echo "   to see which IP address we have MongoDB on, and also which IP"
   echo "   this program is executing on."
   echo ""
   echo "   Currently, you are on the wrong box."
   echo ""
   echo "   If this notice is in error, you must edit the 04* file to proceed."
   echo ""
   echo ""
   exit 2
}


###################################################


#  Run create user
#
echo ""
echo ""
echo "Create MongoDB 'monitor' user, as needed by Appd DB Agent ......"
echo ""
"${MDB_DIR}/bin/mongosh" --quiet ${MY_IP}:${MDB_PORT} > /dev/null  <<EOF
   use admin
   db.createUser(
      {
      user: "${MDB_MONITORUSER}",
      pwd: "${MDB_MONITORPASSWORD}",
         roles: [
            { role: "clusterMonitor", db: "admin" },
            { role: "read", db: "admin" },
         ]
      }
   )
EOF


echo ""
echo ""
echo "Within MongoDB, this program created-"
echo ""
echo "   Username:  ${MDB_MONITORUSER}"
echo "   Password:  ${MDB_MONITORPASSWORD}"
echo ""
echo "   ** You will only need this info inside the AppD Console"
echo "      when discovering the DB Agent."
echo ""
echo "      Otherwise; MongoDB is operating without Authentication."
echo "         (Without username/passwords)"


###################################################


echo ""
echo ""
echo "Next Steps:"
echo ""
echo "   .  Load data ?   Use program,"
echo "         ./17*"
echo ""
echo "   .  Ensure that the AppD DB Agents are installed/running."
echo ""
echo "   .  If you need the AppD Controller,"
echo "         https://${CONTROLLER_HOST_NAME}/controller"
echo "         Accountname/Username:  ${APPDYNAMICS_AGENT_ACCOUNT_NAME}"

echo ""
echo ""






