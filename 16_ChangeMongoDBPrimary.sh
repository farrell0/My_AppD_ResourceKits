#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to change which MongoDB node is the primary.
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
   #  We are not on a host we want MongoDB on. 
   #  We will terminate this program.
   #
   echo ""
   echo ""
   echo "ERROR:  This program reads the file titled,"
   echo ""
   echo "      04_ImportSettings.sh"
   echo ""
   echo "   to see which IP address we want MongoDB on, and also which IP"
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
###################################################


echo ""
echo ""
echo "The MongoDB database server is installed on two nodes"
echo "in a primary/secondary pair. (A common high availability"
echo "configuration.)"
echo ""
echo "This program must be run from the MongoDB primary, and"
echo "will call for the other MongoDB node to become primary."
echo ""
echo "This operation is non-destructive."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################


l_return=$(echo 'db.isMaster().ismaster' | mongosh --host ${MY_IP} --port ${MDB_PORT} --quiet)

#  Raw output resembles,
#
#     """farrell_mongorepl1 [direct: primary] test> true farrell_mongorepl1 [direct: primary] test>
#

l_cntr=`echo "${l_return}" | grep "\[direct\: primary\]" | wc -l`
   #
[ ${l_cntr} -gt 0 ] && {


"${MDB_DIR}/bin/mongosh" --quiet ${MY_IP}:${MDB_PORT} > /dev/null  <<EOF
   rs.stepDown()
EOF

   echo "INFO:  Operation complete."
   echo ""
   echo ""


} || {
   echo "ERROR: We are not on the MongoDB primary and can not"
   echo "   perform the requested operation."
   echo ""
   echo ""
}




