#!/usr/bin/ksh
IFS="
"
OS=`uname`

case $OS in

        AIX)
                echo "Platform is SunOS.  Using saveqmgr.aix"
                awkver=gawk
                ;;
        SunOS)
                echo "Platform is SunOS.  Using saveqmgr.solaris"
                awkver=nawk
                ;;
        Linux)
                echo "Platform is Linux.  Using saveqmgr.linux"
                awkver=gawk
                ;;
        *)
                echo "$OS not supported.  Termindated."
                echo "Please contact martin.cheng@citi.com."
                exit -1
                ;;
esac
echo "enter # for Queue Manager to work with "
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
break
done
cd /var/mqm/tmp
COMMAND='dis chl(*) type(SDR)'
echo $COMMAND | runmqsc $MENU_QM | grep -v SYSTEM | grep CHANNEL | awk -F\) '{ print $1 }' | awk -F\( '{ print $2 }' >> $$.out
echo "****** the following channels are senders ******"
echo $COMMAND | runmqsc $MENU_QM |more
echo "enter to stop all channels or ctrl-c to break out of script - this is you last chance before execution "
select x in $(cat $$.out)
do
CHANNEL=${x}
break
done
while read LINE
do

        COMMAND='stop channel('${LINE}') status(inactive)'
	echo $COMMAND | runmqsc $MENU_QM

#echo "$LINE"
        :

done < $$.out
rm $$.out
cd -

