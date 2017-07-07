#!/usr/bin/ksh
IFS="
"
#echo "enter # for Queue Manager to work with "
#select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
#do
#MENU_QM=${x}
#break
#done
echo "Enter # for command to work with "
select c in $(cat unix.lst)
do
COMMAND=${c}
break
done
eval $COMMAND
./commonly_used_unix_commands.sh
