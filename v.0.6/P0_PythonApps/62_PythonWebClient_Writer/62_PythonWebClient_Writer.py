


#############################################################


import os;
import time;
import requests;


#############################################################


MY_PYTHON_WEBSERVER_IP   = os.getenv("MY_PYTHON_WEBSERVER_IP");
MY_PYTHON_WEBSERVER_PORT = os.getenv("MY_PYTHON_WEBSERVER_PORT");
MY_SERVICEURL1           = ("http://" + MY_PYTHON_WEBSERVER_IP +
                           ":" + MY_PYTHON_WEBSERVER_PORT + "/");

#############################################################
#############################################################


#  When we run this as an AppD "instrumented" app, we inherit
#  additional stdout/stderr output.
#
#  So that we may direct those elsewhere (versus our own output),
#  we run this code.
#
import argparse;
import functools;

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


#############################################################
#############################################################


if __name__ == "__main__":

   def f_get(i_url):
      l_response = requests.get(i_url);
      return l_response;

   l_loopcntr = 0;

   while(True):

      time.sleep(1);
      l_loopcntr += 1;
         #
      print("I looped: " + str(l_loopcntr));

      l_response = f_get(MY_SERVICEURL1);
         #
      print(str(l_response.status_code));









