#!/usr/bin/ksh
# -----------------------------------------------------------
# 01_SSL_Channels.ksh
#
# Solution for Module 01 of the WMQ Security Lab
#
#
#
# 20100312 T.Rob - New script
#
# -----------------------------------------------------------
cd "$(cd "$(dirname "$0")"; pwd)"
TimeStamp=$(date "+%y%m%d-%H%M")
MarsPass="clientpass"
VenusPass="serverpass"

(date;echo)      >>${0##*/}.$TimeStamp.out

print "Setting up MARS and VENUS QMgrs for WMQSECLAB Module 01\n\n" | tee -a ${0##*/}.$TimeStamp.out 

print "Deleting any existing key database files and certificates\n"  | tee -a ${0##*/}.$TimeStamp.out 
rm /var/mqm/qmgrs/MARS/ssl/*  >/dev/null 2>&1
rm /var/mqm/qmgrs/VENUS/ssl/* >/dev/null 2>&1

print "Creating SSL client key database for MARS" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -keydb -create -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -type cms -expire 365 -stash -fips >>${0##*/}.$TimeStamp.out 2>&1

print "Deleting unused signer certificates from MARS kdb.  This step was omitted from" | tee -a ${0##*/}.$TimeStamp.out 
print "the lab for brevity but should be performed for actual implementations." | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -list  -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -fips | grep ^! | cut -f 2 | {
    while read _cert;do
        print "\tDeleting certificate '$_cert'" | tee -a ${0##*/}.$TimeStamp.out 
        runmqakm -cert -delete -label "$_cert" -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -fips >/dev/null 2>&1
    done
}

print "\nCreating SSL server key database for VENUS" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -keydb -create -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -type cms -expire 365 -stash -fips >>${0##*/}.$TimeStamp.out 2>&1

print "Deleting unused signer certificates from VENUS kdb.  This step was omitted from" | tee -a ${0##*/}.$TimeStamp.out 
print "the lab for brevity but should be performed for actual implementations." | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -list  -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -fips | grep ^! | cut -f 2 | {
    while read _cert;do
        print "\tDeleting certificate '$_cert'" | tee -a ${0##*/}.$TimeStamp.out 
        runmqakm -cert -delete -label "$_cert" -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -fips >/dev/null 2>&1
    done
}

print "\nSetup MARS client certificate" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -create -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -label ibmwebspheremqmars -dn "CN=MARS,OU=IMPACT,OU=WMQSECLAB,OU=TEST,O=IBM,L=LAS VEGAS,ST=NV,C=USA" -expire 365 -fips -sigalg sha1 >>${0##*/}.$TimeStamp.out 2>&1

print "Setup VENUS client certificate" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -create -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -label ibmwebspheremqvenus -dn "CN=VENUS,OU=IMPACT,OU=WMQSECLAB,OU=TEST,O=IBM,L=LAS VEGAS,ST=NV,C=USA" -expire 365 -fips -sigalg sha1 >>${0##*/}.$TimeStamp.out 2>&1

if test -e /var/mqm/qmgrs/MARS/ssl/MARS.crt; then;print Cert exists; exit 1; fi

print "\nCopy the public SSL client certificate to the SSL server side" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -extract -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -label ibmwebspheremqmars -target /var/mqm/qmgrs/MARS/ssl/MARS.crt -format ascii -fips >>${0##*/}.$TimeStamp.out 2>&1
print "add" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -add -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -label ibmwebspheremqmars -file /var/mqm/qmgrs/MARS/ssl/MARS.crt -format ascii -fips >>${0##*/}.$TimeStamp.out 2>&1
print "list" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -list -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -fips >>${0##*/}.$TimeStamp.out 2>&1
print

print "Copy the public SSL server certificate to the SSL client side" | tee -a ${0##*/}.$TimeStamp.out 
runmqakm -cert -extract -db "/var/mqm/qmgrs/VENUS/ssl/VENUS.kdb" -pw $VenusPass -label ibmwebspheremqvenus -target /var/mqm/qmgrs/VENUS/ssl/VENUS.crt -format ascii -fips >>${0##*/}.$TimeStamp.out 2>&1
runmqakm -cert -add -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -label ibmwebspheremqvenus -file /var/mqm/qmgrs/VENUS/ssl/VENUS.crt -format ascii -fips >>${0##*/}.$TimeStamp.out 2>&1
runmqakm -cert -list -db "/var/mqm/qmgrs/MARS/ssl/MARS.kdb" -pw $MarsPass -fips >>${0##*/}.$TimeStamp.out 2>&1

print "\nSet file permisions for VENUS keystore" | tee -a ${0##*/}.$TimeStamp.out 
chmod g+r /var/mqm/qmgrs/VENUS/ssl/*

print "\nSet file permisions for MARS keystore" | tee -a ${0##*/}.$TimeStamp.out 
chmod g+r /var/mqm/qmgrs/MARS/ssl/*

print "\nRun the object definitions for VENUS" | tee -a ${0##*/}.$TimeStamp.out 
runmqsc VENUS >>${0##*/}.$TimeStamp.out << EOFVENUS 2>&1
* Object definitions for VENUS
STOP CHANNEL('MARS.VENUS')
DEFINE CHANNEL('MARS.VENUS') CHLTYPE(RCVR) TRPTYPE(TCP) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA) SSLCAUTH(REQUIRED) SSLPEER('CN=MARS,OU=TEST,OU=WMQSECLAB,OU=IMPACT,L=LAS VEGAS,ST=NV,C=USA') REPLACE
START CHANNEL('MARS.VENUS')
ALTER QMGR SSLKEYR('/var/mqm/qmgrs/VENUS/ssl/VENUS') SSLFIPS(YES)
REFRESH SECURITY TYPE(SSL)
EOFVENUS


print "\nRun the object definitions for MARS" | tee -a ${0##*/}.$TimeStamp.out 
runmqsc MARS  >>${0##*/}.$TimeStamp.out << EOFMARS 2>&1
* Object definitions for MARS
STOP CHANNEL('MARS.VENUS')
DEFINE CHANNEL('MARS.VENUS') CHLTYPE(SDR) TRPTYPE(TCP) XMITQ('VENUS') CONNAME('localhost(1414)') SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA) SSLPEER('CN=VENUS,OU=TEST,OU=WMQSECLAB,OU=IMPACT,O=IBM,L=LAS VEGAS,ST=NV,C=USA') REPLACE
DEFINE QL(VENUS) USAGE(XMITQ) TRIGGER TRIGTYPE(FIRST) REPLACE
START CHANNEL('MARS.VENUS')
ALTER QMGR SSLKEYR('/var/mqm/qmgrs/MARS/ssl/MARS') SSLFIPS(YES)
REFRESH SECURITY TYPE(SSL)
EOFMARS

print "\nWaiting for channel..." | tee -a  ${0##*/}.$TimeStamp.out 
while [[ 1 ]]; do
   Status=$(print "START CHANNEL('MARS.VENUS')\ndis chs(*)" | runmqsc MARS | tr ')' '\n' | grep -E 'STATUS|AMQ8420' | tr '(' '\n' | grep -v STATUS)
   print "\t$Status" | tee -a  ${0##*/}.$TimeStamp.out 
   if [[ "$Status" = "RUNNING" ]]; then; break; fi
   if [[ "$Status" = "RETRYING" ]]; then; break; fi
   sleep 1
done

print "\n${0##*/} done.  Output log saved to   ${0##*/}.$TimeStamp.out\n"

# End of script
exit 1
