#set -x
# Determine the platform to obtain the gsk7cmd path based on platform
platform=`uname -a | cut -f1 -d' '`

case $platform in

        AIX )
                key=/usr/opt/ibm/gskta/bin/gsk7cmd
                ;;
        Linux )
                key=/usr/local/ibm/gsk7/bin/gsk7cmd
                ;;
        SunOS )
                key=/opt/ibm/gsk7/bin/gsk7cmd
                ;;
esac

dspmq
echo "Choose which QM to work with"
IFS="
"
select x in $(dspmq |awk '{print $1}' | sed -e "s/.*(//g" -e "s/).*//g")
do
MENU_QM=${x}
break
done
qmgr_ssl_dir=$(echo 'dis qmgr sslkeyr' | runmqsc ${MENU_QM} | grep SSLKEYR | sed -e "s/.*(//g" -e "s/).*//g" | sed 's/....$//')
cd $qmgr_ssl_dir

$key -cert -list -db key.kdb -pw mcz > /var/mqm/tmp/listallcert.lst

while read LINE
do
certlabel=$(echo "$LINE" | awk '{ FS = "\t" ; print $1 }' | cut -c 4-)
        #$key/gsk_print-kdb "$LINE"
        $key -cert -details -db key.kdb -label "${certlabel}" -pw mcz


#echo "$LINE"
        :

done < /var/mqm/tmp/listallcert.lst

