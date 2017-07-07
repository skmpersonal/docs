#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

_PROG=${0##*/}
_QMGR=${1}
TimeStamp=$(date "+%y%m%d-%H%M")

# Did we get QMgr names passed in?
if [[ $# != 1 ]]
then
    echo Usage: $_PROG QMgr
    echo This script authorizes the mqmmqi group for SVRCONN channels
    exit 1
fi

# Verify the QMgr is running
if [[ $(dspmq -m $_QMGR 2>&1 | grep -i Running) == "" ]]
then
	echo QMgr $_QMGR must be running to update its channel definitions.
	exit 1
fi

/usr/bin/ksh -v >$_PROG.$_QMGR.$TimeStamp.out 2>&1 << EOF
# --------------------------------------------------------------------
# $_PROG run on $_DATE by `whoami` for QMgr $_QMGR
# Output file is: 
# $_PWD/$_PROG.$_QMGR.$TimeStamp.out
# 
# --------------------------------------------------------------------

# Allow MCAUSER to connect to QMgr
setmqaut -m $_QMGR -g mqmmqi -t qmgr -all +connect +inq +dsp

# Allow inquire/display of non-queue objects
setmqaut -m $_QMGR -g mqmmqi -n '**' -t namelist -all +dsp +inq
setmqaut -m $_QMGR -g mqmmqi -n '**' -t process  -all +dsp +inq
setmqaut -m $_QMGR -g mqmmqi -n '**' -t authinfo -all +dsp +inq
setmqaut -m $_QMGR -g mqmmqi -n '**' -t channel  -all +dsp
setmqaut -m $_QMGR -g mqmmqi -n '**' -t service  -all +dsp
setmqaut -m $_QMGR -g mqmmqi -n '**' -t listener -all +dsp
setmqaut -m $_QMGR -g mqmmqi -n '**' -t clntconn -all +dsp 

# Default allow-all browse,inq and dsp to all queues
setmqaut -m $_QMGR -g mqmmqi -n '**' -t queue -all +browse +inq +dsp

# Allow limited access to command queue.
setmqaut -m $_QMGR -g mqmmqi -n 'SYSTEM.ADMIN.COMMAND.QUEUE' -t queue  -all +inq +put +dsp

# Allow access to SYSTEM.MQEXPLORER.REPLY.MODEL if it exists.
setmqaut -m $_QMGR -g mqmmqi -n 'SYSTEM.MQEXPLORER.REPLY.MODEL' -t queue -all +inq +put +get +dsp +clr

# Allow access to SYSTEM.DEFAULT.MODEL.QUEUE.
setmqaut -m $_QMGR -g mqmmqi -n 'SYSTEM.DEFAULT.MODEL.QUEUE' -t queue -all +inq +put +get +dsp +clr

# Activate the profiles by placing the mqmmca user ID into the channel's
# MCAUSER and restarting the channel:
echo "ALTER CHL(SYSTEM.ADMIN.SVRCONN) CHLTYPE(SVRCONN) MCAUSER('mqmmqi')" | runmqsc $_QMGR
echo "STOP CHL(SYSTEM.ADMIN.SVRCONN) STATUS(INACTIVE) MODE(FORCE)" | runmqsc $_QMGR

# Enable authorization events in case they were turned off at some point
echo "ALTER QMGR AUTHOREV(ENABLED)" | runmqsc $_QMGR

# --------------------------------------------------------------------
# E N D   O F   S C R I P T
# --------------------------------------------------------------------
EOF
# End of script
exit 1
