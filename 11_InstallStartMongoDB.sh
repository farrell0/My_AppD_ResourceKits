#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to install and start MongoDB, more
#  specifically, a 2-node MongoDB replica set.
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


echo ""
echo ""
echo "This program will perform all steps necessary to start a MongoDB database"
echo "(version 6.0.6) that will operate on ${MY_IP}:${MDB_PORT}"
echo ""
echo "   .  The MongoDB database will run in the background (forked). You will"
echo "      be given the PID."
echo "   .  Any data placed in the MongoDB database will be preserved between"
echo "      MongoDB restarts."
echo ""
echo "   .  Dont't fret if you see an error to the effect of,"
echo ""
echo "         MongoServerError: replSetInitiate quorum check failed because"
echo "         not all proposed set members responded affirmatively ..."
echo ""
echo "      Chicken and egg; this just means that the other MongoDB host is"
echo "      not started/operating yet. (A step you should complete soon.)"
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


###################################################
###################################################


echo ""
echo "Checking (apt) and related dependencies ..."
echo ""
apt update                                                                   &> /dev/null
apt -y install curl                                                          &> /dev/null
apt -y install iproute2                                                      &> /dev/null
   #
apt-get -y install libcurl4 libgssapi-krb5-2 libldap-common libwrap0         &> /dev/null
apt-get -y install libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit   &> /dev/null
apt-get -y install snmp openssl liblzma5                                     &> /dev/null
   #
apt --fix-broken install                                                     &> /dev/null
   #
apt update                                                                   &> /dev/null


###################################################


echo ""
echo "Deleting any past MongoDB database log files, if present ..."
echo ""
   #
[ ! -d "${MDB_DIR}" ] && mkdir -p "${MDB_DIR}"
   #
chmod 777 "${MDB_DIR}"
rm -f     "${MDB_DIR}/logfile*"


[ ! -f "${MDB_DIR}/bin/mongos" ] && {
   echo ""
   echo "MongoDB binary not found: installing now ..."
   echo ""
      #
   l_pwd=`pwd`
   cd "${MDB_DIR}"
      #
   echo "   (MongoDB database software itself.)"
   curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2204-6.0.6.tgz -o mongo.tgz  &> /dev/null
      #
   tar xf mongo.tgz   &> /dev/null
   rm -fr mongo.tgz
   cp -r mongodb-linux-x86_64-ubuntu2204-6.0.6/* .
   rm -fr mongodb-linux-x86_64-ubuntu2204-6.0.6
      #
   echo "   (MongoDB Shell.)"
   curl https://downloads.mongodb.com/compass/mongosh-2.1.1-linux-x64.tgz -o mongos.tgz  &> /dev/null
      #
   tar xf mongos.tgz   &> /dev/null
   rm -fr mongos.tgz
   cp -r mongosh-2.1.1-linux-x64/* .
   rm -fr mongosh-2.1.1-linux-x64
      #
   echo "   (MongoDB Tools.)"
   curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.9.4.tgz -o mongot.tgz  &> /dev/null
      #
   tar xf mongot.tgz   &> /dev/null
   rm -fr mongot.tgz
   cp -r mongodb-database-tools-ubuntu2204-x86_64-100.9.4/* .
   rm -fr mongodb-database-tools-ubuntu2204-x86_64-100.9.4
      #
   mkdir data
   chmod 777 data
      #
   cd "${l_pwd}"
   }


###################################################


echo ""
echo "Starting MongoDB ..."
echo ""
"${MDB_DIR}/bin/mongod"                     \
   --dbpath  "${MDB_DIR}/data"              \
   --logpath "${MDB_DIR}/logfile"           \
   --bind_ip "${MY_IP}"                     \
   --replSet "${MY_USERNAME}_mongorepl1"    \
   --port ${MDB_PORT} --fork  &> /dev/null
      #
l_pid=`ps -ef | grep "bin/mongod" | head -1 | awk '{print $2}'`
echo "The MongoDB database server PID is: "${l_pid}
echo "   kill -15 ${l_pid}      #  To kill"
echo ""


###################################################


#  Sleep 2, just to give MongoDB a chance to come up-
#
sleep 2
   #
"${MDB_DIR}/bin/mongosh" --quiet ${MY_IP}:${MDB_PORT}  <<EOF
rs.initiate(${MDB_REPLCONF})
EOF


###################################################


echo ""
echo ""
echo "Next Steps:"
echo ""
echo "   \"${MDB_DIR}/bin/mongosh\" --quiet ${MY_IP}:${MDB_PORT}"
echo ""
echo '''
         show dbs;

         use my_dbprod;
            //
         db.my_collection.drop();
         db.createCollection("my_collection");
         
         db.my_collection.insertOne( {"state" : "XX", "zip" : 55555 } )
         db.my_collection.insertOne( {"state" : "CO", "zip" : 66666 } )
         db.my_collection.insertOne( {"state" : "WI", "zip" : 77777 } )
         db.my_collection.insertOne( {"state" : "TX", "zip" : 88888 } )
         db.my_collection.insertOne( {"state" : "YY", "zip" : 99999 } )
            // 
         db.my_collection.find( { "state" : { "$in" : [ "CO" , "WI" ] } } )
            // 
         db.my_collection.countDocuments({})

         //  quit
'''

echo ""
echo ""




