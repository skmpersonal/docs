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
COMMAND='dis chs(*) where(status NE RUNNING)'
echo $COMMAND | runmqsc $MENU_QM | grep CHANNEL | awk -F\) '{ print $1 }' | awk -F\( '{ print $2 }' >> $$.out
echo "****** the following channels are not RUNNING *******"
echo $COMMAND | runmqsc $MENU_QM |more
echo "enter # for channel to seek error log file "
select x in $(cat $$.out)
do
CHANNEL=${x}
break
done
QNAME=$(ls /var/mqm/qmgrs| grep ${MENU_QM})
select x in $(ls /var/mqm/qmgrs/$QNAME/errors)
do
#tail -100 /var/mqm/qmgrs/$MENU_QM/errors/$x |view
#vi +/$CHANNEL /var/mqm/qmgrs/$QNAME/errors/$x
#cat /var/mqm/qmgrs/$QNAME/errors/$x | grep -c 10 $CHANNEL
$awkver 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print;c=a}b{r[NR%b]=$0}' b=33 a=2 s=$CHANNEL /var/mqm/qmgrs/$QNAME/errors/$x >$$.out ;vi + $$.out
break
done
rm $$.out
cd -

