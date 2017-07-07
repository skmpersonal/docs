set -x
. ./exportmqport
# y=$(ps -ef | grep runmqlsr | grep -v 'grep'| awk '{ print $11 }')
FILENAME="lastmqtest"
while read y
do
echo $y
        :
q=$y
done < $FILENAME
#runmqsc $y < mqsc_test.tst
echo $q
read pause
/opt/mqm/samp/bin/amqsputc SYSTEM.DEFAULT.LOCAL.QUEUE $q < testmessage
/opt/mqm/samp/bin/amqsgetc SYSTEM.DEFAULT.LOCAL.QUEUE $q
#runmqsc $y < mqsc_rm_test.tst

