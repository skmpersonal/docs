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
COMMAND='dis chl(*) type(SVRCONN) where(SSLCIPH EQ '\'\'')'
echo $COMMAND | runmqsc $MENU_QM | grep -v SYSTEM | grep CHANNEL | awk -F\) '{ print $1 }' | awk -F\( '{ print $2 }' >> $$.out
echo "****** the following channels are svrconn ******"
echo $COMMAND | runmqsc $MENU_QM |more
echo "enter to alter all channels or ctrl-c to break out of script - this is you last chance before execution "
select x in $(cat $$.out)
do
CHANNEL=${x}
break
done
while read LINE
do

        COMMAND='ALTER CHANNEL('${LINE}') CHLTYPE(SVRCONN) SSLCIPH(NULL_SHA)'
	echo $COMMAND
	echo $COMMAND | runmqsc $MENU_QM

#echo "$LINE"
        :

done < $$.out
rm $$.out
cd -

