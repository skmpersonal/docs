#!/usr/bin/ksh
IFS="
"
echo "enter # for Queue Manager to work with "
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
break
done
echo "dis qstatus(*) where (curdepth gt 0) ALL" | runmqsc $MENU_QM |more
