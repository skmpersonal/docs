This folder contains the scripts to set up the working environment for the lab.  These include setup of the queue manager, the channels and the queues.  Scripts named build.ksh create the environment necessary to run the module.  Scripts named solve.ksh complete the module.  The provided scripts apply to the WebSphere MQ environment.  Modifications to WebSphere MQ Explorer must be applied by hand, or by importing the settings file provided.

The lab assumes that various users and groups have already been created.  If you want to run the lab in your own environment, you will need to greate the following accounts and groups:

Account     Group
-------     -------
mqmmci      mqmmci
mqmmca      mqmmca

In addition, the lab assumes the following prereqs:

* The Q program from SupportPac MA01 has been installed into /opt/mqm/bin.
* The PATH contains /opt/mqm/bin:/opt/mqm/samp/bin
* SupportPac MS0P bas been installed into WMQ Explorer.
* SupportPac MO04 has been downloaded.


The lab's VMWare image uses the SupportPac MSL1 Linux LSB init scripts to start any queue managers at boot time.  If you do not have these or similar scripts installed, you may need to start the queue managers.
