#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

function _MQSC {

TimeStamp=$(date "+%y%m%d-%H%M")

(date;echo)      >"${1}.$TimeStamp.out"
print Ending any existing ${1} queue manager instance   | tee -a ${1}.$TimeStamp.out 
endmqm -i ${1}  >>"${1}.$TimeStamp.out"  2>&1 
print Deleting any existing ${1} queue manager instance | tee -a ${1}.$TimeStamp.out 
dltmqm ${1}     >>"${1}.$TimeStamp.out"  2>&1 
if test -d /var/mqm/sockets/${1}; then; rm -R /var/mqm/sockets/${1}; fi
print Creating ${1} queue manager | tee -a ${1}.$TimeStamp.out 
crtmqm ${1}     >>"${1}.$TimeStamp.out"  2>&1 
print Starting ${1} queue manager | tee -a ${1}.$TimeStamp.out 
strmqm ${1}     >>"${1}.$TimeStamp.out"  2>&1 
print Building ${1} QMgr objects  | tee -a ${1}.$TimeStamp.out 
runmqsc ${1}  >>"${1}.$TimeStamp.out"  2>&1 << EOF
* -----------------------------------------------------------
* ${0##*/} - Define ${1} objects
*
* 20110227 T.Rob - New script
*
* -----------------------------------------------------------
dis qmgr qmname

* Queue Manager Name ${1}

*Local Queues for testing auths

DEFINE QLOCAL ('AUTHORIZED.LOCAL.QUEUE') +
       DESCR('For testing auths') +
       REPLACE


*  SVRCONN Definitions

DEFINE CHANNEL ('SYSTEM.ADMIN.SVRCONN') CHLTYPE(SVRCONN) +
       TRPTYPE(TCP) +
       MCAUSER('mqm') +
       REPLACE

*  Create TCP Listener on port ${2}
DEFINE LISTENER(TCP.${2}) TRPTYPE(TCP) +
       CONTROL(QMGR) +
       PORT(${2}) +
       REPLACE

START LISTENER(TCP.${2})

*  Create Trigger Monitor Service

DEFINE SERVICE(RUNMQTRM) +
       CONTROL(QMGR) +
       SERVTYPE(SERVER) +
       STARTCMD('+MQ_INSTALL_PATH+bin/runmqtrm') +
       STARTARG('-m +QMNAME+ -q SYSTEM.DEFAULT.INITIATION.QUEUE') +
       STOPCMD('+MQ_INSTALL_PATH+bin/amqsstop') +
       STOPARG('-m +QMNAME+ -p +MQ_SERVER_PID+')  +
       REPLACE

START  SERVICE(RUNMQTRM)

	   
* -----------------------------------------------------------
* Standard QMgr alterations
* -----------------------------------------------------------
ALTER  QMGR DEADQ('${1}.DEAD.LETTER.QUEUE') +
       FORCE

DEFINE QLOCAL ('${1}.DEAD.LETTER.QUEUE') +
	   DESCR('Queue Manger Dead Letter Queue Do not delete ') +
       REPLACE

ALTER QMGR AUTHOREV(ENABLED)
* -----------------------------------------------------------
* E N D   O F   S C R I P T
* -----------------------------------------------------------
EOF

}

# Run the object definitions in
_MQSC VENUS 1414
_MQSC MARS  1415

dspmq


print Clean up user mqm SSL directory  | tee -a ${1}.$TimeStamp.out
test -d /home/MQLab/ssl && rm -f /home/MQLab/ssl/* >/dev/null 2>&1


print Clean up exit logs  | tee -a ${1}.$TimeStamp.out
rm -f /var/mqm/exits/*.log >/dev/null 2>&1

# End of script
exit 1
