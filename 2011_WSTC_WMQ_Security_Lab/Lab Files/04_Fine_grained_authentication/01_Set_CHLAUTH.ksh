#!/usr/bin/ksh
# -----------------------------------------------------------
# 01_Enable_exit.ksh
#
# Solution for Module 04 of the WMQ Security Lab
#
#
#
# 20100312 T.Rob - New script
#
# -----------------------------------------------------------
cd "$(cd "$(dirname "$0")"; pwd)"
TimeStamp=$(date "+%y%m%d-%H%M")


(date;echo)>>${0##*/}.$TimeStamp.out

clear
print "Module 4 - \n\n" | tee -a ${0##*/}.$TimeStamp.out 

print "Altering SYSTEM.ADMIN.SSL on MARS" | tee -a ${0##*/}.$TimeStamp.out 
runmqsc MARS  >>${0##*/}.$TimeStamp.out << EOFMARS 2>&1
ALTER QMGR CHLAUTH(ENABLED)
SET CHLAUTH(SYSTEM.ADMIN.SSL) TYPE(SSLPEERMAP) +
SSLPEER('CN=MQLab,OU=TEST,OU=WMQSECLAB,OU=IMPACT') +  
MCAUSER('mqadmin')
ALTER CHANNEL(SYSTEM.ADMIN.SSL) CHLTYPE(SVRCONN) TRPTYPE(TCP) MCAUSER('nobody')
EOFMARS

print "Altering SYSTEM.ADMIN.SSL on VENUS" | tee -a ${0##*/}.$TimeStamp.out 
runmqsc VENUS  >>${0##*/}.$TimeStamp.out << EOFVENUS 2>&1
ALTER QMGR CHLAUTH(ENABLED)
SET CHLAUTH(SYSTEM.ADMIN.SSL) TYPE(SSLPEERMAP) +
SSLPEER('CN=MQLab,OU=TEST,OU=WMQSECLAB,OU=IMPACT') +  
MCAUSER('mqadmin')
ALTER CHANNEL(SYSTEM.ADMIN.SSL) CHLTYPE(SVRCONN) TRPTYPE(TCP) MCAUSER('nobody')
EOFVENUS

print "Give mqadmin persmissions on MARS" | tee -a ${0##*/}.$TimeStamp.out 
# These commands give group 'mqadmin' full administrative access on WebSphere MQ for UNIX and Linux.
setmqaut -m MARS -t qmgr -g mqadmin +connect +inq +alladm
setmqaut -m MARS -n "**" -t q -g mqadmin +alladm +crt +browse
setmqaut -m MARS -n "**" -t topic -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t channel -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t process -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t namelist -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t authinfo -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t clntconn -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t listener -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t service -g mqadmin +alladm +crt
setmqaut -m MARS -n "**" -t comminfo -g mqadmin +alladm +crt

# The following commands provide administrative access for MQ Explorer.
setmqaut -m MARS -n SYSTEM.MQEXPLORER.REPLY.MODEL -t q -g mqadmin +dsp +inq +get
setmqaut -m MARS -n SYSTEM.ADMIN.COMMAND.QUEUE -t q -g mqadmin +dsp +inq +put

print "Give mqadmin persmissions on VENUS" | tee -a ${0##*/}.$TimeStamp.out 
# These commands give group 'mqadmin' full administrative access on WebSphere MQ for UNIX and Linux.
setmqaut -m VENUS -t qmgr -g mqadmin +connect +inq +alladm
setmqaut -m VENUS -n "**" -t q -g mqadmin +alladm +crt +browse
setmqaut -m VENUS -n "**" -t topic -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t channel -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t process -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t namelist -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t authinfo -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t clntconn -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t listener -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t service -g mqadmin +alladm +crt
setmqaut -m VENUS -n "**" -t comminfo -g mqadmin +alladm +crt

# The following commands provide administrative access for MQ Explorer.
setmqaut -m VENUS -n SYSTEM.MQEXPLORER.REPLY.MODEL -t q -g mqadmin +dsp +inq +get
setmqaut -m VENUS -n SYSTEM.ADMIN.COMMAND.QUEUE -t q -g mqadmin +dsp +inq +put


print "\n${0##*/} done.  Output log saved to   ${0##*/}.$TimeStamp.out\n"

# End of script
exit 1
