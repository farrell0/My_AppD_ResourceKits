My Cisco/AppDynamics -- Resource Kits
===================

| **[vers. 0.6.alpha](https://github.com/farrell0/My_AppD_ResourceKits/blob/master/README.md)**| **[vers. 0.7 - Coming](https://github.com/farrell0/My_AppD_ResourceKits/blob/master/v.0.7/README.md)**|
|-------------------------|--------------------------|

This is a personal blog where I post programs, data files, other (a Resource Kit), used in the delivery of serveral "Lunch and Learns" using the Cisco/AppDynamics full stack observability platform. 


vers. 0.6.alpha - -  Python single page Web app, MongoDB database in a 2-node replica set, additional readers and writers, and more.


>Problem Statement:
>
>Your customer complains that the public Web site is slow. Find the root cause, and fix it.
>
>Resource Kit contents:
>
>.  Runners for every command; no coding required, every non-AppD function is scripted/automated.
>
>.  Bigger footprint, (sorry); this exercise expects 6 (count) local VMs at 4GM RAM, 3 Cores each, static IPs. We also expect a cloud hosted AppD system.
>
>.  From the above, we run; 2 nodes of MongoDB in a primary/seconday (HA) config, a node for AppD DB Agents and the AppD Web Console, and 3 more nodes for a Python/Flask Web server, one Python reader client, and one Python writer client.
>
>.  We set up all of the agents, run AppD REST API command to validate changes, yadda.
>
>.  Net/net; find what's wrong with the Web app. Everything that is wrong is repairable with a tunable that the Web app will implement.
>