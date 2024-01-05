

#  Single page Web application written in Python. Displays geo-
#  spatial data using MongoDB.
#
#  .  Web page will serve at THIS_IP:THIS_PORT
#
#     There are instructions on this Web page; How this program
#     functions.
#

#  Helpful page on the topic of MongoDB HA,
#     https://pymongo.readthedocs.io/en/stable/examples/high_availability.html
#


#############################################################
## Imports ##################################################


#  When we run this as an AppD "instrumented" app, we inherit
#  additional stdout/stderr output.
#
#  So that we may direct those elsewhere (versus our own output),
#  we run this code.
#
import argparse
import functools

l_parser = argparse.ArgumentParser();
l_parser.add_argument("--logfile", type=str);
    #
l_args = l_parser.parse_args();

if l_args.logfile:
   #
   #  We rececived the command line parameter titled,
   #  --logfile
   #
   #  Redirect print() to said file.
   #
   l_logfile = open(l_args.logfile, "w");
      #
   print = functools.partial(print, file=l_logfile, flush=True);


   #############################


#  This import allows us to use a directory other than the
#  default for Flask CSS files and related.
#
#  And we generate random numbers to force static files to
#  reload, and not from cache.
#
import os;
import random;


#  So that we may control logging level output.
#
import logging


#  Flask is our Python based Web server.
#
#  These are all in try-except blocks to hopefully make
#  this easier to install/use.
#
try: 
   from flask import (Flask, render_template, request, 
      jsonify, make_response);
   from jinja2 import Template
   from jinja2.filters import FILTERS, pass_environment
except:
   os.system("pip install flask");
   from flask import (Flask, render_template, request, 
      jsonify, make_response);
   from jinja2 import Template
   from jinja2.filters import FILTERS, pass_environment


#  Geohash library; converts lat/long pair to geohash, and
#  also the reverse.
#
try: 
   import libgeohash as gh;
except:
   os.system("pip install libgeohash");
   import libgeohash as gh;


#  MongoDB, database connectivity
#
try: 
   from pymongo import MongoClient, ReadPreference
except:
   os.system("pip install pymongo")
   from pymongo import MongoClient, ReadPreference


#############################################################
## Inits, Opens, and Sets ###################################


#  IP and port to run this Web server on.
#
THIS_IP         = os.getenv("MY_PYTHON_WEBSERVER_IP");
THIS_PORT       = os.getenv("MY_PYTHON_WEBSERVER_PORT");

#  Where to find MongoDB
#
MDB_IP1         = os.getenv("MDB_IP1");
MDB_IP2         = os.getenv("MDB_IP2");
MDB_PORT        = os.getenv("MDB_PORT");
   #
MDB_REPLICASET  = os.getenv("MDB_REPLICASET");

#  Other MongoDB settings
#
MDB_SECONDARY   = os.getenv("MDB_SECONDARY");
MDB_QUERYCOLUMN = os.getenv("MDB_QUERYCOLUMN");
   #
print();
if (MDB_QUERYCOLUMN is None):
   MDB_QUERYCOLUMN = "geo_hash5";
print("INFO: MongoDB, query column is (" +
   MDB_QUERYCOLUMN + ").");


   #############################


#  If these environment variables are not set,
#  they come back as "None" type, which throws
#  an error on the string concatentation.
#
try:
   l_connstr    = (
      "mongodb://" +
      MDB_IP1 + ":" + MDB_PORT +
      "," +
      MDB_IP2 + ":" + MDB_PORT
      );
except:
   print();
   print();
   print("ERROR:  The MongoDB connection string is messed" +
      " up.");
   print();
   print("   This happens when we fail to import the '04*" +
      " settings'");
   print("   file prior to execution.");
   print();
      #
   exit(2);


#  Setting up in support of MongoDB HA
#
if (MDB_SECONDARY is None):
   l_dbhandle = MongoClient(l_connstr,
      replicaSet=MDB_REPLICASET, readPreference=
      "primaryPreferred");
   print("INFO: MongoDB, Primary preferred.");
else:
   #
   #  Another option is,  "secondaryPreferred"
   #
   l_dbhandle = MongoClient(l_connstr,
      replicaSet=MDB_REPLICASET, readPreference=
      "nearest");
   print("INFO: MongoDB, Secondary allowed.");
print();
print();
      #
l_database    = l_dbhandle["my_dbprod" ];
l_collection1 = l_database["my_mapdata"];
l_collection2 = l_database["my_logdata"];


   #############################


#  We set logging level to ERROR (versus INFO).
#
#  Still, it's nice to get some output to the console,
#  so we'll control that via this variable.
#
l_numreqsreceived = 0;

#  Instantiate Flask object.
#
#  Flask is our lightweight Web server.
#
m_app = Flask(__name__);
   #
l_log = logging.getLogger("werkzeug");
l_log.setLevel(logging.ERROR);


#  Set Flask defaults for locating files
#
m_templateDir = os.path.abspath("./45_views" );
m_staticDir   = os.path.abspath("./44_static");
   #
m_app.template_folder = m_templateDir;
m_app.static_folder   = m_staticDir;


#############################################################
## Our Web pages (page handlers) ############################


#  This is a Jinja2 (our Python Flask/Bottle template engine),
#  custom filter.
#  
#  Effectively, we rewrite any filenames/Urls that come
#  in, adding a unique suffix.
#
@pass_environment
def autoversion(self, i_fname):

   #  Generate a unique number to disable browser cache.
   #
   l_uniq     = random.randint(0, 100000);
   l_newfname = "{0}?v={1}".format(i_fname, l_uniq);
      #
   return l_newfname

#  Required for the above to be seen by Jinja2.
#
FILTERS["autoversion"] = autoversion


      ###############################################


#  We supress INFO logging to the console.
#
#  Still, it'd be nice to see something once in a while.
#
@m_app.before_request
def log_request_info():

   global l_numreqsreceived;
      #
   l_numreqsreceived += 1;
      #
   if (l_numreqsreceived > 1000):
      l_numreqsreceived = 0;
         #
      print();
      print("#########################################");
      print();
      print("Every 1000 requests, we conditionally output one request:");
      print("Headers.............");
      print("%s" % str(request.headers).strip());
      # print("%s" % str(request.headers).strip());
      print("Request arguments...");
      print("   %s" % str(request.args).strip());


      ###############################################


#  This is our main page.
#
#  This is a single page Web app; after this page loads,
#  everything else is just data/AJAX.
#
@m_app.route("/")
def do_servePage():
   return render_template("60_Index.html");


      ###############################################


#  Fyi:  An oddity below-
#
#     We query using one of two geohash data columns
#     as a query filter.
#
#     When limitting the number of rows returned from 
#     the query, one of the columns provided a better
#     spread of data directionally (North, East, South,
#     and so on). The other column did not.
#
#     So .. .. if you limit the number of columns
#     returned to a low enough value, you might see
#     only (North data, and not South data) etcetera.
#
#     Nothing is broken. this is just how the data is
#     accessed.
#


#  This is our query response (page)
#
@m_app.route("/_do_query")
def do_query():

   l_lat        = request.args.get("h_lat"        );
   l_lng        = request.args.get("h_lng"        );
   l_textFilter = request.args.get("h_textFilter" );
   l_limit      = request.args.get("h_limit"      );
   #
   #  The actual Web (browser) client does not send this.
   #
   #  Our Python read-only client program does.  
   #
   if (l_limit is None):
      l_limit   = 1000;

   #  For debugging.
   #
   #  print(request.args);

   l_latLng  = gh.encode(float(l_lat), float(l_lng),
      precision=5);
         #
   l_markers = f_query(l_latLng, l_textFilter, int(l_limit));
      #
   return jsonify(l_markers);


      ###############################################


#  While our Python Application Client Reader is labeled
#  a (reader), it does also write a very small amount
#  of diagnostic data.
#
@m_app.route("/_do_insert")
def do_insert():

   l_insertdict = {
      "l_ts"                : request.args.get("l_ts"               ),
      "l_avgbusy"           : request.args.get("l_avgbusy"          ),
      "prc_tp_per_unittime" : request.args.get("prc_tp_per_unittime"),
      "prc_unittime_secs"   : request.args.get("prc_unittime_secs"  ),
      "l_avg_latency"       : request.args.get("l_avg_latency"      ),
      "m_numof200s"         : request.args.get("m_numof200s"        ),
      "m_numofnot200s"      : request.args.get("m_numofnot200s"     ),
      "g_numof200s"         : request.args.get("g_numof200s"        ),
      "g_numofnot200s"      : request.args.get("g_numofnot200s"     ),
      "g_numofnotidles"     : request.args.get("g_numofnotidles"    ),
      "g_doccountread"      : request.args.get("g_doccountread"     ),
      "g_bytesread1"        : request.args.get("g_bytesread1"       ),
      "g_bytesread2"        : request.args.get("g_bytesread2"       ),
   };
   f_insert(l_insertdict);
      #
   return jsonify({});


#############################################################
## Helper functions              ############################


#  Sample output from gh.neighbors(),
#
#    {'e': '9xj3v', 'sw': '9xj3e', 'ne': '9xj6j', 'n': '9xj6h',
#       's': '9xj3s', 'w': '9xj3g', 'se': '9xj3t', 'nw': '9xj65'}
#

def f_query(i_latLng, i_textFilter, i_limit):
   global m_client;


   #  Building our query string when a name is specified for
   #  a business. 
   #
   i_textFilter = i_textFilter.lower()
   
   #  An array we use with each of the compass points.
   #
   l_locats = [];

   #  Level 0 neighbors, centerpoint
   #
   l_loca_C0 = i_latLng;
      #
   l_locats.append({"key": "C0", "val": l_loca_C0});
   
   #  Level 1 neighbors, close to the centerpoint.
   #
   l_neighbors1 = gh.neighbors(l_loca_C0);
      #
   l_locats.append({"key": "N1" , "val": l_neighbors1["n" ]});
   l_locats.append({"key": "S1" , "val": l_neighbors1["s" ]});
   l_locats.append({"key": "E1" , "val": l_neighbors1["e" ]});
   l_locats.append({"key": "W1" , "val": l_neighbors1["w" ]});
   l_locats.append({"key": "NE1", "val": l_neighbors1["ne"]});
   l_locats.append({"key": "NW1", "val": l_neighbors1["nw"]});
   l_locats.append({"key": "SE1", "val": l_neighbors1["se"]});
   l_locats.append({"key": "SW1", "val": l_neighbors1["sw"]});
   
   #  Level 2 neighbors, an additional distance from the
   #  centerpoint.
   #
   l_locats.append({"key": "N2" , "val": gh.neighbors(
      l_neighbors1["n" ])["n"] });
   l_locats.append({"key": "S2" , "val": gh.neighbors(
      l_neighbors1["s" ])["s"] });
   l_locats.append({"key": "E2" , "val": gh.neighbors(
      l_neighbors1["e" ])["e"] });
   l_locats.append({"key": "W2" , "val": gh.neighbors(
      l_neighbors1["w" ])["w"] });
   l_locats.append({"key": "NE2", "val": gh.neighbors(
      l_neighbors1["ne"])["ne"]});
   l_locats.append({"key": "NW2", "val": gh.neighbors(
      l_neighbors1["nw"])["nw"]});
   l_locats.append({"key": "SE2", "val": gh.neighbors(
      l_neighbors1["se"])["se"]});
   l_locats.append({"key": "SW2", "val": gh.neighbors(
      l_neighbors1["sw"])["sw"]});


   #  This MongoDB index is no longer required; we filter 
   #  manually below.
   #
   #     db.my_mapdata.ensureIndex({"md_name": 1});
   #
   
   #  Building/running the final query ..
   #
   l_values = [each.get("val", None) for each in l_locats];
   
   
   #  Below; We variably query against a given column.
   #
   #  Know, however, that the value of "geo_hash5" equals
   #  the value of "geo_hash5_idx". So .. .. we only need
   #  to output one in the result set.
   #
   l_pipeline = [
      { "$match": {MDB_QUERYCOLUMN: {"$in": l_values}} },
      { "$project": {"l_idx1": "n/a", "md_lat": 1, "md_lng": 1,
         "md_name": 1, "md_address": 1, "md_city": 1,
         "md_province": 1, "md_phone": 1, "md_subcategory": 1,
         "_id": 0, "geo_hash5": 1}
      },
      { "$limit": i_limit}
   ];

   #  If we didn't manually loop thru the cursor, we were
   #  not getting complete results.
   #
   l_cursor = l_collection1.aggregate(l_pipeline);
   l_result = [];
      #
   for each in l_cursor:
      l_result.append(each);

   #  We are manually filtering our matching string since
   #  MongoDB aggregate with an AND and a ReGex to get a
   #  leading string was taking too long to develop.
   #
   l_result2 = [];
      #
   for each in range(len(l_result)):
      try:
         if (l_result[each]["md_name"][0:len(i_textFilter)].
               lower() == i_textFilter):
            l_result2.append(l_result[each]);
      except:
         #
         #  About 0.2% of the data is missing a value here;
         #  just pass over it.
         #
         pass;
   
   #  We need to update a given property for each row of the array.
   #
   for each in range(len(l_result2)):
      l_hash5 = l_result2[each]["geo_hash5"];
      l_locat = [each for each in l_locats if each["val"] ==
         l_hash5][0]["key"];
            #
      l_result2[each]["l_idx1"] = l_locat;

   return l_result2;


      ###############################################


def f_insert(i_dict):
   global m_client;

   try:
      l_result = l_collection2.insert_one(i_dict);
   except:
      #
      #  We'll ingore errors for now.
      #
      pass;


#############################################################
#############################################################


#
#  And then; running our Web site proper.
#
if __name__=='__main__':
   
   m_app.run(host = THIS_IP, port = int(THIS_PORT), debug=True);







