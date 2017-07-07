#!/usr/bin/ksh
IFS="
"
echo "enter # for Queue Manager to work with "
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
break
done
echo "Enter # for command to work with "
select c in $(cat mqsc.lst)
do
COMMAND=${c}
break
done
cd /var/mqm/tmp
echo $COMMAND | runmqsc $MENU_QM |more > $$.out
vi $$.out
rm $$.out
cd -
