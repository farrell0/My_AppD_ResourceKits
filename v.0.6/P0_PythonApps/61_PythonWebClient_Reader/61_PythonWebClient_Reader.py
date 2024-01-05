

#  Program to drive read-only traffic against our Python Web
#  Server.
#


#############################################################
## Imports                    ###############################
#############################################################


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


#  Used to read environment variables.
#
import os;

#  Used to sleep, control transactions per second of our
#  fetch loop.
#
import time

#  Used to make Http requests of our Python Web server.
#
import requests


#############################################################
## Constants                  ###############################
#############################################################


#  This program loops thru an ASCII text file containing key
#  values. These keys are used to parameterize a Web service
#  invocation.
#
#  These last 2 variable control the rate of execution.
#
PRC_KEYFILENAME          = os.getenv("PRC_KEYFILENAME");
   #
PRC_TP_PER_UNITTIME      = int(os.getenv("PRC_TP_PER_UNITTIME"));
PRC_UNITTIME_SECS        = int(os.getenv("PRC_UNITTIME_SECS"));

#  Number of database rows we fetch with every query to 
#  the database.
#
MY_HLIMIT                = 400;

#  This program to output statistics every (n) seconds.
#
MY_REPORT_SECS=60;


#  Where to find our Python Web service server-
#
MY_PYTHON_WEBSERVER_IP   = os.getenv("MY_PYTHON_WEBSERVER_IP");
MY_PYTHON_WEBSERVER_PORT = os.getenv("MY_PYTHON_WEBSERVER_PORT");
   #
MY_SERVICEURL1           = ("http://" + MY_PYTHON_WEBSERVER_IP +
                           ":" + MY_PYTHON_WEBSERVER_PORT + "/");
MY_SERVICEURL2           = ("http://" + MY_PYTHON_WEBSERVER_IP +
                           ":" + MY_PYTHON_WEBSERVER_PORT +
                           "/_do_query");
MY_SERVICEURL3           = ("http://" + MY_PYTHON_WEBSERVER_IP +
                           ":" + MY_PYTHON_WEBSERVER_PORT +
                           "/_do_insert");


#  We shouldn't need to change this.
#  In a named variable so it's easier to track.
#
MY_SLEEPTIME_MILLIS      = 100;


#############################################################
#############################################################


#  Processing our ASCII text file containing database
#  key values; we use these values as a filter to 
#  our query activity.
#
def f_getfilehandle(i_fname):
   try:
      r_filehandle = open(i_fname, "r");
      return r_filehandle;
   except FileNotFoundError:
      print();
      print();
      print(f"ERROR: Input file name not found, ({file_name}).");
      print();
      print();
      exit(2);

def f_readoneline(i_filehandle):
   if (i_filehandle is not None):
      r_line = i_filehandle.readline().strip();
      #
      #  Handling end of file, and automatic restart.
      #
      if (len(r_line) < 1):
         i_filehandle.seek(0);
         r_line = f_readoneline(l_filehandle);
      return r_line;
   else:
      return None;


#  Returned in milliseconds.
#
def f_get_time():
   return (int(round(time.time() * 1000)));

#  time.sleep(n) is synchronous.
#
def f_sleep_millis(i_arg):
   time.sleep(i_arg / 1000);


#############################################################
#############################################################


def f_startmsg():

   print();
   print();
   print("This Python program makes remote read-only Web service" +
      " requests against");
   print("our Python Web server. (This program is a Web client.)");
   print();
   print("Additionally, it is stated:");
   print();
   print("   .  There are (" + str(PRC_TP_PER_UNITTIME) + 
      ") read-only transactions per (transaction group).");
   print("      We run a transaction group every (" +
      str(PRC_UNITTIME_SECS) + ") secs.");
   print("         (This is tunable in the *04 file.)");
   print();
   print("   .  We read (" + str(MY_HLIMIT) + ") count of" +
      " rows from the database with every transaction.");
   print("      (First we read the static HTML page, then" +
      " we run a routine that calls");
   print("      a MongoDB database query; so two calls.)");
   print();
   print("   .  Every (" + str(MY_REPORT_SECS) + ") seconds" +
      " this program outputs a diagnostic message.");
   print();
   print();
   print("** What to watch for:");
   print();
   print("   This program (and others) have the ability to saturate");
   print("   the Python Web server and application as a whole.");
   print("   Thus, you may want to change the count of transactions");
   print("   and related that this program executes.");
   print();
   print("   See file *04 for settings pertaining to this task.");
   print();
   print();
   print("Program running ...");
   print();


def f_reportmsg():

   #  Here is the sample output sent to the screen.
   #
   #     INFO:  Avg busy (last tx group only)...(TX/N-SEC)................ 13%     (2-tx/10-secs)
   #     Avg latency in millis per 1-call (last tx group only)......... 229
   #     Count of Http-200/!200 (last tx group only)................... 24/0
   #     Count of Http-200/!200 (since program start).................. 24/0
   #     Since program start, occasions of zero idle time.............. 0
   #     Since program start, bytes-read1/bytes-read2/docu-count....... 0.38-M/1.41-M/4.80K
   #
   print("INFO:  Avg busy (last tx group only)...(TX/N-SEC)" +
      "................ " + l_avgbusy + "%     (" + str(
      PRC_TP_PER_UNITTIME) + "-tx/" + str(PRC_UNITTIME_SECS) +
      "-secs)");
   print("   Avg latency in millis per 1-call (last tx group" +
      " only)......... " + str(l_avg_latency));
   print("   Count of Http-200/!200 (last tx group only)......" +
      "............. " + str(m_numof200s) + "/" +
      str(m_numofnot200s));
   print("   Count of Http-200/!200 (since program start)...." +
      ".............. " + str(g_numof200s) + "/" +
      str(g_numofnot200s));
   print("   Since program start, occasions of zero idle" +
     " time.............. " + str(g_numofnotidles));
        #
   if (g_doccountread > 1000000):
      l_doccountread_f = str(f"{(g_doccountread / 1000000):.2f}") + "M";
   else:
      l_doccountread_f = str(f"{(g_doccountread / 1000):.2f}")    + "K";
         #
   print("   Since program start, bytes-read1/bytes-read2/" +
      "docu-count....... " + f"{(g_bytesread1 / 1024 / 1024):.2f}" +
      "-M/" + f"{(g_bytesread2 / 1024 / 1024):.2f}" + "-M/" +
      l_doccountread_f);
   print();

   #  Sending that same diagnostic information to the database.
   #
   #  Build the header for our Web service invocation.
   #  And execute the Web service invocation call.
   #
   l_params = {
      "Content-Type"       : "application/json",
      "l_ts"               : l_time_startouterloop,
      "l_avgbusy"          : l_avgbusy,
      "prc_tp_per_unittime": PRC_TP_PER_UNITTIME,
      "prc_unittime_secs"  : PRC_UNITTIME_SECS,
      "l_avg_latency"      : l_avg_latency,
      "m_numof200s"        : m_numof200s,
      "m_numofnot200s"     : m_numofnot200s,
      "g_numof200s"        : g_numof200s,
      "g_numofnot200s"     : g_numofnot200s,
      "g_numofnotidles"    : g_numofnotidles,
      "g_doccountread"     : g_doccountread,
      "g_bytesread1"       : g_bytesread1,
      "g_bytesread2"       : g_bytesread2
   };
   try:
      l_response = requests.get(MY_SERVICEURL3,
         params=l_params);
   except Exception as e:
      print(f"ERROR: {e.__class__}, {str(e)}");


#############################################################
#############################################################


#  Our program main.
#
if __name__=='__main__':


   #  Print the start message.
   #
   f_startmsg();


         ##################################


   #  Initializations (that affect program flow)-
   #

   #  Opening the ASCII text file that contains the key values
   #  we send as part of our Web service invocation request.
   #
   l_filehandle  = f_getfilehandle(PRC_KEYFILENAME);
     
   #  Used to calculate sleep time;
   #     Effectively, we manually manage how quickly this loop
   #     runs a number of (transactions) per unit time.
   #
   #  This is "time in loop", effectively; the amount of time 
   #  needed to loop one time thru an entire unit of work.
   #  That is, one set of the number of requested transactions.
   #
   l_time_startouterloop = f_get_time();

   #  How many times has this (transactions/inner) loop,
   #  has looped.
   #
   l_curr_tpcntr = 0;

   #  Used to track amount of seconds between "reporting", that
   #  is; this program outputting status data.
   #
   l_report_secs = f_get_time();


         ##################################


   #  Other initializations (used for reporting only)-
   #
   g_numof200s       = 0;             #  Forever/global count of
                                      #  Http 200 return codes
   g_numofnot200s    = 0;             #  Count of not 200 codes
   m_numof200s       = 0;             #  Same as above, but for
                                      #  one reporting cycle only
   m_numofnot200s    = 0;             #  And again, the "not" codes.

   m_time_exec       = 0;             #  Per each inner loop
                                      #  completion, how much exec
                                      #  time did we have.
   m_time_idle       = 0;             #  Per each inner loop 
                                      #  completion, how much idle
                                      #  time did we have.
   g_numofnotidles   = 0;             #  Per each outer loop, number 
                                      #  of occasions we had zero
                                      #  idle time.

   g_bytesread1      = 0;             #  Bytes read from the 1st
   g_bytesread2      = 0;             #  Web service and the 2nd.
   g_doccountread    = 0;             #  Doc count from from 2nd.
  

         ##################################
         ##################################


   #  Run this program until interrupted.
   #
   while(True):

      #  We run a given number of (transactions) per
      #  unit time, as reflected in the variable,
      #     PRC_TP_PER_UNITTIME.
      #
      #  So, first loop that number of times regardless of
      #  time spent.
      #
      while (l_curr_tpcntr < PRC_TP_PER_UNITTIME):

         #  Our [ inner ] loop counter.
         #
         l_curr_tpcntr+=1;

         #
         #  Get the next key value from our ASCII text file. 
         #  These values are used as a parameter to our Web
         #  service invocation.
         #
         l_thisline = f_readoneline(l_filehandle);
            #
         l_lat = l_thisline.split("|")[0];
         l_lng = l_thisline.split("|")[1];
   
         #  Build the header for our Web service invocation.
         #  And execute the Web service invocation call.
         #
         l_params = {
            "Content-Type": "application/json",
            "h_lat"       : l_lat,
            "h_lng"       : l_lng,
            "h_textFilter": "",
            "h_limit"     : MY_HLIMIT
         };

         ##################################

         #
         #  Do the call to get just the full Html Web page.
         #
         #  You can comment out this block, should you wish.
         #
         #  We get highly variable (~ number of Http requests
         #  exceeded), so we catch those.
         #
         try:
            l_response = requests.get(MY_SERVICEURL1,
               params=l_params);
                  #
            if (l_response.status_code == 200):
               g_numof200s    += 1;
               m_numof200s    += 1;
               g_bytesread1   += len(l_response.text);
            else:
               g_numofnot200s += 1;
               m_numofnot200s += 1;
         except Exception as e:
            print(f"ERROR: {e.__class__}, {str(e)}");
            print();
               #
            g_numofnot200s += 1;
            m_numofnot200s += 1;

         ##################################

         #
         #  Do the call to run the data query.
         #
         #  (A method available from this page.)
         #
         try:
            l_response = requests.get(MY_SERVICEURL2,
               params=l_params);
                  #
            if (l_response.status_code == 200):
               g_numof200s    += 1;
               m_numof200s    += 1;
               g_bytesread2   += len(l_response.text);
               g_doccountread += len(l_response.json());
            else:
               g_numofnot200s += 1;
               m_numofnot200s += 1;
         except Exception as e:
            print(f"ERROR: {e.__class__}, {str(e)}");
            print();
               #
            g_numofnot200s += 1;
            m_numofnot200s += 1;
               

         ##################################

          
      #  The end of our first 'inner loop'.
      #  Above we were running the Web service invocation.
      #
      #  Gather stats; how much time were we executing 
      #  (versus waiting to loop, so we don't loop too
      #  fast).
      #
      l_time_exec = (f_get_time() - l_time_startouterloop);
      m_time_exec += l_time_exec;
         #
      #  print("Execution time was (milliseconds): " +
      #     str(l_time_exec));
      l_avg_latency = int(l_time_exec / PRC_TP_PER_UNITTIME);


      #  We're done with our work-work; should we now 
      #  sleep, so that we do not execute too quickly ?
      #
      if (((f_get_time() - l_time_startouterloop) / 1000)
            >= PRC_UNITTIME_SECS):
         #
         #  We took more time for a transaction group than
         #  is allowed.
         #  Record this fact.
         #  And, we do not need to sleep.
         #
         g_numofnotidles += 1;
         l_time_idle = 0;
      else:
         while (((f_get_time() - l_time_startouterloop) /
               1000) < PRC_UNITTIME_SECS):
            f_sleep_millis(MY_SLEEPTIME_MILLIS);
         l_time_idle = (f_get_time() -
            l_time_startouterloop - l_time_exec);

      #
      #  Record event of having slept.
      #
      m_time_idle += l_time_idle;
         #
      #  print("Idle time was (milliseconds): " +
      #     str(l_time_idle));


      #  Reset for next iteration of "outer loop";
      #  (the next grouping of transactions).
      #
      l_time_startouterloop = f_get_time();
      l_curr_tpcntr = 0;
         
      #  Is it time to report to the user ?   MMM
      #
      if (((l_report_secs / 1000) + MY_REPORT_SECS) <
            (f_get_time() / 1000)):
         #
         #  It's time to report to the end user.
         #
         l_avgbusy = str( int((m_time_exec / (m_time_exec + m_time_idle
               ) * 100)) );
         f_reportmsg();  
         #
         #  Reset our tracking variables.
         #
         m_numof200s    = 0;
         m_numofnot200s = 0;
         m_time_exec    = 0;
         m_time_idle    = 0;
            #
         l_report_secs = f_get_time();


   #  End of parent loop from above
   #


         ##################################
         ##################################


   #  Post our while/true loop above.
   #
   l_filehandle.close();










