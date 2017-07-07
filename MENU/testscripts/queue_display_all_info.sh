#!/usr/bin/ksh
dspmq
echo "Choose which QM to work with"
IFS="
"
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
break
done
cd /var/mqm/tmp
        QMGR=$MENU_QM

        for i in aliasq-d localq-d   remoteq-d  svrconn-d  xmitq-d allchan-d
        do
                cp /dev/null ${i}
        done

rm allchan
#       Step #2 - Collect localq, xmitq, remoteq & svrconn data

        echo "dis ql(*) where(usage ne xmitq)" | runmqsc ${QMGR} | grep QUEUE | grep -v SYSTEM | grep -v MQMGM | grep -v NASTEL | grep -v MQCONTROL | grep -v CITI.DLQ | grep -v PUBSUB.DLQ  > localq-d
        echo "dis ql(*) where(usage eq xmitq)" | runmqsc ${QMGR} | grep QUEUE | grep -v SYSTEM > xmitq-d
        echo "dis qr(*)" | runmqsc ${QMGR} | grep QUEUE | grep -v SYSTEM > remoteq-d
        echo "dis qa(*)" | runmqsc ${QMGR} | grep QUEUE | grep -v SYSTEM > aliasq-d
        echo "dis chl(*) where(chltype eq svrconn)" | runmqsc ${QMGR} | grep CHANNEL | grep -v SYSTEM > svrconn-d
	rm allqueue-d allqueue
	cat localq-d xmitq-d > allqueue-d
        echo "dis chl(*)" | runmqsc ${QMGR} | grep CHANNEL | grep -v SYSTEM > allchan-d
#exit 0
#       Step #1 - Parse raw data into files

        for i in localq xmitq remoteq aliasq svrconn allchan allqueue
        do
                cat ${i}-d | awk -F\) '{ print $1 }' | awk -F\( '{ print $2 }' >> ${i}
        done
#cat allchan
#read test
#        cat allchan | grep -v CHANNEL >allchan

select x in $(cat allqueue)
do
command="dis ql(${x}) all"
echo $command | runmqsc $MENU_QM 
echo "********************** pausing before - queue status ***********************"
read pause
command="dis qs(${x}) all"
echo $command | runmqsc $MENU_QM 
break
done
cd -
