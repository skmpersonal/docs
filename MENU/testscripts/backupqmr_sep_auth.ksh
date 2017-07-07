#!/bin/ksh

# Martin Cheng 12-07-2011
# backupqmgr.ksh Version 0.4

# This script does two things.

# 1. It utilities the saveqmgr support pac to create .tst backup files.
# The logic is really simple.  The script loops through the output of "dspmq" to
# determine if a queue manager is running.
# If so, saveqmgr is run against that queue manager and the output is written 
# to a file named "QMgrName@hostname.DateTime.saveqmgr.out".  
#
# 2. It runs "amqoamd -m QmgrName -s " and appends the output at the end of 
# the file in 1. This way we everything in one place.  All the setmqaut 
# are prefixed with an "*" so we will not get errors if we were to
# feed the output file directly to runmqsc.
#
# In additon, you can specify how many backup files you want to keep.  
# Default is 14.

# Version 0.4 added AIX support
# Version 0.4 added email notification to author 

#set -x 

host=`hostname`
datetime=`date +%m-%d-%y.%H:%M:%S`
copies=14

# location of the saveqmgr executable
saveqmgrdir=`pwd`/saveqmgr

# location of the output files
outputdir=/var/mqm


backupqmgrVersion="0.4 12-07-2011"
echo "backupqmgr Version" $backupqmgrVersion


# First find out the platform we are running on

OS=`uname`

case $OS in 

	AIX)
		echo "Platform is SunOS.  Using saveqmgr.aix"
		saveqmgrexe=saveqmgr.aix
                mailvar=mailx
		;;
	SunOS)
		echo "Platform is SunOS.  Using saveqmgr.solaris"
		saveqmgrexe=saveqmgr.solaris
                mailvar=mailx
		;;
	Linux) 
		echo "Platform is Linux.  Using saveqmgr.linux"
		saveqmgrexe=saveqmgr.linux
                mailvar=mail
		;;
	*)
		echo "$OS not supported.  Termindated."
		echo "Please contact martin.cheng@citi.com."
		exit -1	
		;;
esac

MQVersion=`dspmqver -b -f2 | cut -b 1-3 | tr -d .` 

case $MQVersion in 
	53)
		echo "MQ Version is 53"
		;;
	60)
		echo "MQ Version is 6"
		;;
	70)
		echo "MQ Version is 7"
		;;
	*)
		echo "Not a supported MQ Version. Terminated."
		echo "Please contact martin.cheng@citi.com."
		exit -1
		;; 
esac;

saveqmgrVersion=`$saveqmgrdir/$saveqmgrexe -h 2>&1 | grep "SAVEQMGR V"` 
echo $saveqmgrVersion 

# FYI author
mailtext="Host: `hostname` \n`date` \nbackupqmgr Version: $backupqmgrVersion \nMQ Version: $MQVersion \nOS: $OS saveqmgr Version: $saveqmgrVersion"

qmgrs=`dspmq | awk '{ print $1"%"$2 }' | sort`
for qm in $qmgrs 
do
	echo $qm | grep -i running > /dev/null
	if [ $? -eq 0 ]
	then
		qmgrname=`echo $qm | cut -f1 -d\) | cut -f2 -d\(`

		mailtext="$mailtext \nQMgr: $qmgrname"
		filename=$outputdir/$qmgrname@$host.$datetime.saveqmgr.out
		echo Creating backup file $filename
		# saveqmgr
		$saveqmgrdir/$saveqmgrexe -ns -m $qmgrname -f $filename > /dev/null 2>&1
		# amqoamd
		#echo "* setmqaut commands..." >> $filename
		filename1=$outputdir/$qmgrname@$host.$datetime.saveqmgr.auth.out	
		amqoamd -m $qmgrname -s  >> $filename1
		echo "Enter your email address here ... ie mark.gebel@citi.com to get copy of saveqmgr : "
		read mailinfo

		echo $mailtext | $mailvar -s "backupqmgr execution" $mailinfo < $filename
		cnt=`ls -tr $outputdir/$qmgrname@$host* | wc -l`
		if [ $cnt -gt $copies ] 
		then
			echo Current number of copies reaching limit of $copies.
			oldestfile=`ls -tr  $outputdir/$qmgrname@$host* | head -1 | awk '{print $1}'`
			echo "Removing oldest copy $oldestfile"
			rm -f $oldestfile
		fi
		echo ""
	fi
done

#echo $mailtext | $mailvar -s "backupqmgr execution" mark.gebel@citi.com < $filename
