#!/usr/bin/ksh
dspmq
echo "Choose which QM to work with"
IFS="
"
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
export MENU_QM
echo $x
break
done
sed -i "s/GTUATEF01/${x}/g" /var/mqm/prod_qmx/gather_data_script
sed -i "s/GTUATEF01/${x}/g" /var/mqm/prod_qmx/create_apply_script
echo 'what is the app MQC ? '
read mqc
sed -i "s/${mqc}/mqcprd1/g" /var/mqm/prod_qmx/create_apply_script
