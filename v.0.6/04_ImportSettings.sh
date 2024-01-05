#!/bin/bash


#  Tested on; Ubuntu 22.04.2 LTS, and no where else.
#
#     cat /etc/os-release
#

#  This file sets variables used throughout the
#  collection of scripts found in this folder.
#


################################################
################################################


#  THIS FIRST GROUP SHOULD BE THE ONLY VARIABLES 
#  YOU NEED TO CUSTOMIZE TO GET THINGS TO WORK
#  IN A NEW ENVIRONMENT.
#

#  Unique identifer
#
#  Used to generate unique identifiers as witnessed
#  by the AppD Controller. Eg, AppD Collectors.
#
#  The MY_APPNAME is hard coded in some of the *.cfg
#  files.
#
export MY_USERNAME=XXXXXXX
export MY_APPNAME="farrell-python-app"


#  Local install(s) directory
#
#  Directory to create things on each node.
#  Eg., where we AppD install agents, other.
#
export PARENT_DIR="/opt/AD"


#  MongoDB tier
#
#  We expect to run two MongoDB nodes in an HA
#  configuration. These are those IP addresses.
#
#  A bit of hard coding to reduce complexity; 
#  there must be two hosts here, and no other
#  number.
#
#  Bash does not yet export arrays. We can use
#  them as variables, just not for export.
#
MDB_IPS=("192.168.182.20" "192.168.182.21")
   #
export MDB_IP1="192.168.182.20"
export MDB_IP2="192.168.182.21"
#
#  While the MDB servers do not require authentication,
#  the OS/host does. This password is used for ssh(C),
#  and the AppD DB Agent to gather OS realted stats.
#
export MY_ROOTPASSWORD="XXXXXXXX"


#  DBAgents tier
#
#  The IP address of the node operating the two
#  DB Agents.
#
export DBAGENT_IP="192.168.182.22"


#  Target AppD Controller (remote)
#
#  Which AppD Controller to use ?
#
#  Here we follow the exact AppD environment
#  variable names.
#
export CONTROLLER_HOST_NAME="XXXXXXXXXXX.appdynamics.com"
export APPDYNAMICS_CONTROLLER_PORT=443
export APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
   #
export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="XXXXXXXXXXXX"
export APPDYNAMICS_AGENT_ACCOUNT_NAME="XXXXXX"


#  An Auth-token generated from the AppD Controller
#  we specified above.
#
#  See,
#     https://docs.appdynamics.com/appd/onprem/latest/en/extend-appdynamics/appdynamics-apis/api-clients
#
#  But basically,
#     Controller  -->  Gear Icon  -->  Administration  --> API Clients  -->  +/CREATE
#
#     ** The longest token grant time is 30 days.
#
export MY_APPD_ADMINAUTHTOKEN="eyJraWQiOiI0YjYwOTAwOS05ZjkwLTR XXXXXXXXXXXXXXXXX 6LTdC19uzBMlWRoZon5n8uiO8"
   #
export MY_APPD_ADMINAUTHTOKEN_DATE="December 22, 2023"


#  JAVA_HOME (required for agents)
#
#  If not set, or not set correctly, you might first
#  see this error when starting the DB Agent,
#
#     Error: A JNI error has occurred, please check your installation and try again
#     Exception in thread "main" java.lang.NoClassDefFoundError: com/singularity/ee/util/logging/ILogger
#
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64


#  Python Web App Server tier
#
#  IP address and port of the Python App Web server
#
export MY_PYTHON_WEBSERVER_IP="192.168.182.23"
export MY_PYTHON_WEBSERVER_PORT=3000


#  Python Read Client tier
#
#  The expected IP address of the Python read client
#  program.
#
export PRC_IP="192.168.182.24"


#  Python Write Client tier
#
#  The expected IP address of the Python write client
#  program.
#
export PWC_IP="192.168.182.25"


################################################
################################################


#  WHILE THERE ARE TUNABLES BELOW, GENERALLY YOU
#  SHOULD NOT NEED TO SET ANYTHING BELOW THIS LINE.
#

#  Who are we (routine)
#
#  What is [ our/this ] IP address ?
#

#  This is wrong for this use; this is the public IP.
#
#  MY_IP=`curl ident.me 2> /dev/null`
#
#  This is kind of hinky because we hard code the ID
#  of the (virtual) ethernet network interface card;
#  getting our IP address.
#
#  We use this value to see if we are running given
#  programs on the correct box.
#
export MY_IP=`ifconfig ens33 | grep "inet " | awk '{print $2}'`


################################################


#  MongoDB specific settings
#

#  This is also kind of hinky; as written, we only
#  handle two hosts in this MongoDB replica set.
#
export MDB_REPLICASET="${MY_USERNAME}_mongorepl1"
   #
export MDB_REPLCONF='{
_id : "'${MY_USERNAME}'_mongorepl1",
   members : [
      {_id : 0, host : "'${MDB_IPS[0]}'"},
      {_id : 1, host : "'${MDB_IPS[1]}'"},
   ]
}'


#  Other MongoDB settings
#
export MDB_PORT=27017
   #
export MDB_DIR="${PARENT_DIR}/10_MongoDB"
export MDB_DATADIR="${PARENT_DIR}/10_MongoDB/data"

export PATH="${PATH}:${MDB_DIR}/bin"

#  Created within MongoDB, Used by the AppD
#  DB Agent
#
#  Wound up not using these; but leaving them
#  set.
#
export MDB_MONITORUSER="XXXXXXXXXXXXXXXXXXX"
export MDB_MONITORPASSWORD="XXXXXXXX"

#  SMALL  == we load just Colorado data, about
#  200K lines
#
#  LARGE  == we load Colorado and Texas data. 
#  Texas adds an addition 1.2M lines.
#
#  export MDB_LOADAMOUNT="SMALL"
export MDB_LOADAMOUNT="LARGE"

#  Tuning, performance  (MMM)
#
#  export MDB_SECONDARY="OK"
#  export MDB_QUERYCOLUMN="geo_hash5_idx"


################################################


#  AppD DB Agent settings
#
#  Where to install the DB Agent
#
export DBAGENT_DIR="${PARENT_DIR}/20_DBAgent_Installed"


################################################


#  Python Web Server settings
#

#  This group also shared by the Python Read and
#  Write clients
#
export MACHAGENT_DIR="${PARENT_DIR}/60_MachAgent_Installed"
export PYTHONAGENT_DIR="${PARENT_DIR}/61_PythonAgent_Installed"


################################################


#  Python Read Client Settings
# 

#  We run a Python Web server, and two Python client
#  programs.
#
#  The first Python client program runs read-only
#  operations against the Web server, and its
#  configurable settings are here,
#
#  "PRC" is short for, Python read client
#
export PRC_KEYFILENAME="../../K1_MongoDBJustKeysFromTestData.CO.TX.txt"
   #
export PRC_TP_PER_UNITTIME=2
export PRC_UNITTIME_SECS=10


################################################


#  Python Write Client Settings
# 






