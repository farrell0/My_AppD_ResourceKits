#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to load a given MongoDB table/collection
#  with 240K rows/documents.
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
###################################################


#  Delete collection first-
#
echo ""
echo ""
echo "This program will error out if not run from the MongoDB"
echo "primary node. And, we don't check for that."
echo ""
echo ""
echo "Return true|false if collection found ..."
echo ""
"${MDB_DIR}/bin/mongosh" --quiet  ${MY_IP}:${MDB_PORT}                             \
   --eval  "use my_dbprod"                                                         \
   --eval  "db.my_mapdata.drop()"                       

l_pwd=`pwd`
   #
echo ""
echo "Create 247,886 documents from the 'Colorado' load file ..."
echo ""
"${MDB_DIR}/bin/mongoimport" --host=${MY_IP}:${MDB_PORT} --type tsv --headerline   \
    --db my_dbprod --collection my_mapdata --file                                  \
   "${l_pwd}/D1_MongoDBTestData.CO.tab"
      #
[ "${MDB_LOADAMOUNT}" = "LARGE" ] && {
   echo ""
   echo "Create 1,122,098 documents from the 'Texas' load file ..."
   echo ""
   "${MDB_DIR}/bin/mongoimport" --host=${MY_IP}:${MDB_PORT} --type tsv --headerline   \
       --db my_dbprod --collection my_mapdata --file                                  \
      "${l_pwd}/D2_MongoDBTestData.TX.tab"
}

echo ""
echo "Check for presence of documents ..."
echo ""
"${MDB_DIR}/bin/mongosh" --quiet ${MY_IP}:${MDB_PORT}  <<EOF
use my_dbprod
db.my_mapdata.countDocuments()
EOF


###################################################


echo ""
   #
echo ""
echo ""
echo "Creating index on specific MongoDB column(s)."
echo ""
echo "MongoDB indexes are created asynchronously. Thus, it may"
echo "be a few moments before your index is created/usable."
echo ""
"${MDB_DIR}/bin/mongosh" --quiet ${MY_IP}:${MDB_PORT}  <<EOF
use my_dbprod
db.my_mapdata.ensureIndex({"md_name":       1})                      
db.my_mapdata.ensureIndex({"geo_hash5_idx": 1})                      
EOF

echo ""
   #
echo ""
echo ""







