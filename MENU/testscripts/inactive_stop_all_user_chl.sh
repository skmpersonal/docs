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
esac
echo "enter # for Queue Manager to work with "
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
break
done
cd /var/mqm/tmp
        for t in SDR SVR RCVR RQSTR 
        do
        COMMAND='dis chl(*) type('${t}')'
        echo $COMMAND | runmqsc $MENU_QM
        echo " *** pausing to show result of list building for each type *** press enter to continue or ctrl-c to breakout"
        read pause
        echo $COMMAND | runmqsc $MENU_QM | grep -v SYSTEM | grep CHANNEL | awk -F\) '{ print $1 }' | awk -F\( '{ print $2 }' >>$$.out
	done
echo "****** the following channels are all user channels YOU MUST ENTER A NUMBER FROM LIST BELOW TO CONTINUE ******"
echo "entering a number from the list below will stop - inactive all channels listed or ctrl-c to break out of script - last chance before execution "
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
