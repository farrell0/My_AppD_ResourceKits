#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS and no where else.
#
#     cat /etc/os-release
#


#  This program will run the MongoDB command shell.
#


#  Import settings from file, ./04*
#
. ./04_ImportSettings.sh


################################################


#  Which box are we trying to run from ?
#
l_flag=false

for l_each in ${MDB_IPS[@]}
   do
   [ "${l_each}" = "${MY_IP}" ] && l_flag=true
   done

[ ${l_flag} = false ] && {
   #
   #  We are not on a host that has MongoDB on it. 
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


################################################
################################################


echo ""
echo ""
echo "Next Steps:"
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

"${MDB_DIR}/bin/mongosh" --quiet ${MY_IP}:${MDB_PORT}




