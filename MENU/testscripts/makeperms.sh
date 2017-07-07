#!/usr/bin/ksh
echo "Choose which QM to work with"
IFS="
"
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
export MENU_QM
break
done

if [ "$MENU_QM" = "" ]
    then
        dspmq
        read MENU_QM
    else
     echo 'in if ' $MENU_QM
fi
cat /etc/group|grep mqc
select x in $(cat /etc/group|grep mqc |awk '{ FS = ":" }{print $1}')
do
mqc=${x}
break
done
echo "Currently working with $MENU_QM"
echo 'setmqaut -m '$MENU_QM' -t qmgr -g '$mqc' +allmqi' > 'set_'$MENU_QM'_perm.sh'
echo 'setmqaut -m '$MENU_QM' -n '\''**'\'' -t q -g '$mqc' +allmqi' >> 'set_'$MENU_QM'_perm.sh'
echo 'setmqaut -m '$MENU_QM' -n '\''MQCONTROL.**'\'' -t q -g '$mqc' -allmqi' >> 'set_'$MENU_QM'_perm.sh'
echo 'setmqaut -m '$MENU_QM' -n '\''NASTEL.**'\'' -t q -g '$mqc' -allmqi' >> 'set_'$MENU_QM'_perm.sh'
echo 'setmqaut -m '$MENU_QM' -n '\''SYSTEM.**'\'' -t q -g '$mqc' -allmqi' >> 'set_'$MENU_QM'_perm.sh'
chmod 775 'set_'$MENU_QM'_perm.sh'

