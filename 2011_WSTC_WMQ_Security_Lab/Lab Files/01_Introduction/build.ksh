#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

# Run build scripts from all prior modules
../00_Initialize/build.ksh

function _MQSC {

TimeStamp=$(date "+%y%m%d-%H%M")

(date;echo)      >"${1}.$TimeStamp.out"
print Building ${1} QMgr objects  | tee -a ${1}.$TimeStamp.out 
runmqsc ${1}  >>"${1}.$TimeStamp.out"  2>&1 << EOF
* -----------------------------------------------------------
* ${0##*/} - Define ${1} objects
*
* 20100303 T.Rob - New script
* 20110227 T.Rob - Split out init to 00_ module
*
* -----------------------------------------------------------
dis qmgr qmname

* Queue Manager Name ${1}


*Local Queue Defintions for Transmit Queueus

DEFINE QLOCAL ('${2}') +
       DESCR('Transmit queue ${2}') +
       USAGE(XMITQ) +
       TRIGGER +
       TRIGTYPE(FIRST) +
       INITQ('SYSTEM.CHANNEL.INITQ') +
       REPLACE

* Loopback queue
DEFINE QREMOTE(${1}.${2}.LPBK) +
       RQMNAME(${2}) +
       RNAME(${2}.${1}.LPBK) +
       XMITQ(' ') +
       REPLACE

*  Channel Definitions

DEFINE CHANNEL ('${1}.${2}') CHLTYPE(SDR) +
       TRPTYPE(TCP) +
       CONNAME('localhost(${4}') +
       DESCR('Sender Channel to ${2} ') +
       XMITQ('${2}') +
       REPLACE

RESET  CHANNEL ('${1}.${2}')

DEFINE CHANNEL ('${2}.${1}') CHLTYPE(RCVR) +
       DESCR('Reciever channel from ${2} ') +	 
       TRPTYPE(TCP) +
       REPLACE

  
* -----------------------------------------------------------
* E N D   O F   S C R I P T
* -----------------------------------------------------------
EOF

}

# Run the object definitions in
_MQSC VENUS MARS 1414 1415
_MQSC MARS VENUS 1415 1414

dspmq

# End of script
exit 1
