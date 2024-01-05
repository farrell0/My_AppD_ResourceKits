#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  Program to report on data present in MongoDB.
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
   #  We are not on a host we can run MongoDB on. 
   #  We will terminate this program.
   #
   echo ""
   echo ""
   echo "ERROR:  This program reads the file titled,"
   echo ""
   echo "      04_ImportSettings.sh"
   echo ""
   echo "   to see which IP address we can run MongoDB on, and also which IP"
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
echo "Read-only report on status of MongoDB collections titled:"
echo "   my_dbprod.my_mapdata"
echo "   my_dbprod.my_logdata"
echo ""
echo ""

l_result1=`"${MDB_DIR}/bin/mongosh" --quiet  ${MY_IP}:${MDB_PORT}   \
   --eval  "use my_dbprod"                                          \
   --eval  "db.my_mapdata.countDocuments()"`
      #
echo "Number of total documents in (my_mapdata)................ ${l_result1}"
echo ""

l_result2=`"${MDB_DIR}/bin/mongosh" --quiet  ${MY_IP}:${MDB_PORT}   \
   --eval  "use my_dbprod"                                          \
   --eval  "db.my_mapdata.distinct('geo_hash5_idx').length"`
      #
echo "Number of unique key values in (geo_hash5)............... ${l_result2}"
l_result3=$((l_result1 / l_result2))
echo "   Average number of unique key values per document...... ${l_result3}"

l_result4=`"${MDB_DIR}/bin/mongosh" --quiet  ${MY_IP}:${MDB_PORT}   \
   --eval  "use my_dbprod"                                          \
   --eval  'db.my_mapdata.aggregate([ { $group : { _id: "$geo_hash5_idx", count: {$sum: 1} } }, { $sort: { count: -1} }, { $limit: 10 } ]);'`
      #
echo ""
echo "Top (n) results, count per unique key value.............."
echo ""
l_result5=`echo $l_result4 | sed 's/\[//g' | sed 's/\]//g' | sed 's/}, /}|/g'`
   #
echo $l_result5 | awk '
   BEGIN {
      RS = "|"
   }
   {
   printf("   %s\n", $0);
   }'

            ###########################

l_result6=`"${MDB_DIR}/bin/mongosh" --quiet  ${MY_IP}:${MDB_PORT}   \
   --eval  "use my_dbprod"                                          \
   --eval  "db.my_logdata.countDocuments()"`
      #
echo "Number of total documents in (my_logdata)................ ${l_result6}"
echo ""

echo "Python application log data.............................."
echo ""
l_result7=`"${MDB_DIR}/bin/mongosh" --quiet  ${MY_IP}:${MDB_PORT}   \
   --eval  "use my_dbprod"                                          \
   --eval  "db.my_logdata.find().sort({l_ts: -1}).limit(1);"`
echo "${l_result7}" | grep -v "\[" | grep -v "\]" | grep -v "\{" |  \
   grep -v "\}" | tr "'," "  " | awk -F ":" '
      {
      printf("%-24s   %-32s\n", $1, $2);
      }'
echo ""
echo ""





