#!/usr/bin/ksh
# -----------------------------------------------------------
# 01_Personal_Keystore.ksh
#
# Solution for Module 03 of the WMQ Security Lab
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
ClientKeyStore=~/ssl/MQLab.jks
ClientCRT=~/ssl/MQLab.crt

export PATH=/opt/mqm/java/jre/bin:/usr/local/ibm/gsk7/bin:/usr/local/ibm/gsk7/lib:$PATH

(date;echo)      >>${0##*/}.$TimeStamp.out

clear
print "Module 3 - Connect WebSphere MQ Explorer to WMQ using SSL\n\n" | tee -a ${0##*/}.$TimeStamp.out 

# First, make sure directory exists, remove any files from prior runs
mkdir -p ~/ssl >/dev/null 2>&1
rm -f ~/ssl/*  2>&1 | tee -a ${0##*/}.$TimeStamp.out 

print "Building keystore MQLab.jks for user MQLab..."  | tee -a ${0##*/}.$TimeStamp.out
keytool -genkey -alias ibmwebspheremqmqlab -keyalg RSA -dname "CN=MQLab,OU=TEST,OU=WMQSECLAB,OU=IMPACT,O=IBM,L=LAS VEGAS,ST=NV,C=USA" -keystore $ClientKeyStore -storepass passw0rd -keypass passw0rd -storetype jks -validity 365

print "Exporting public key from mqm.jks"  | tee -a ${0##*/}.$TimeStamp.out
keytool -export -alias ibmwebspheremqmqlab -file $ClientCRT -storetype jks -keystore $ClientKeyStore -storepass passw0rd

print "Adding MQLab cert to MARS QMgr keystore"  | tee -a ${0##*/}.$TimeStamp.out
runmqakm -cert -delete -label MARS -db /var/mqm/qmgrs/MARS/ssl/MARS.kdb -pw $MarsPass  >/dev/null 2>&1
runmqakm -cert -add -db /var/mqm/qmgrs/MARS/ssl/MARS.kdb -pw $MarsPass -label MQLab -file $ClientCRT -format ascii -fips >>${0##*/}.$TimeStamp.out 2>&1

print "Adding MARS cert to MQLab keystore"  | tee -a ${0##*/}.$TimeStamp.out
keytool -delete -alias MARS -storetype jks -keystore $ClientKeyStore -storepass passw0rd >/dev/null 2>&1
keytool -import -noprompt -alias MARS -file /var/mqm/qmgrs/MARS/ssl/MARS.crt -storetype jks -keystore $ClientKeyStore -storepass passw0rd

print "Adding MQLab cert to VENUS QMgr keystore"  | tee -a ${0##*/}.$TimeStamp.out
runmqakm -cert -delete -label VENUS -db /var/mqm/qmgrs/VENUS/ssl/VENUS.kdb -pw $VenusPass  >/dev/null 2>&1
runmqakm -cert -add -db /var/mqm/qmgrs/VENUS/ssl/VENUS.kdb -pw $VenusPass -label MQLab -file $ClientCRT -format ascii -fips >>${0##*/}.$TimeStamp.out 2>&1

print "Adding VENUS cert to MQLab keystore"  | tee -a ${0##*/}.$TimeStamp.out
keytool -delete -alias VENUS -storetype jks -keystore $ClientKeyStore -storepass passw0rd >/dev/null 2>&1
keytool -import -noprompt -alias VENUS -file /var/mqm/qmgrs/VENUS/ssl/VENUS.crt -storetype jks -keystore $ClientKeyStore -storepass passw0rd

print "\nDone exchanging certificates.  Listing keystores."  | tee -a ${0##*/}.$TimeStamp.out
print "\nContents of $ClientKeyStore"  | tee -a ${0##*/}.$TimeStamp.out
keytool -list -keystore $ClientKeyStore -storepass passw0rd | tee -a ${0##*/}.$TimeStamp.out 
print "\nContents of /var/mqm/qmgrs/MARS/ssl/MARS.kdb"  | tee -a ${0##*/}.$TimeStamp.out
runmqakm -cert -list  -db /var/mqm/qmgrs/MARS/ssl/MARS.kdb -pw $MarsPass  | tee -a ${0##*/}.$TimeStamp.out 
print "\nContents of /var/mqm/qmgrs/VENUS/ssl/VENUS.kdb"  | tee -a ${0##*/}.$TimeStamp.out
runmqakm -cert -list  -db /var/mqm/qmgrs/VENUS/ssl/VENUS.kdb -pw $VenusPass  | tee -a ${0##*/}.$TimeStamp.out 

print "\n\nNow define the channels.\n" | tee -a ${0##*/}.$TimeStamp.out 

print "SYSTEM.ADMIN.SSL on MARS" | tee -a ${0##*/}.$TimeStamp.out 
runmqsc MARS  >>${0##*/}.$TimeStamp.out << EOFMARS 2>&1
DEFINE CHANNEL('SYSTEM.ADMIN.SSL') CHLTYPE(SVRCONN) TRPTYPE(TCP) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA)  SSLCAUTH(REQUIRED) REPLACE
REFRESH SECURITY TYPE(SSL)
ALTER QMGR CHLAUTH(DISABLED)
EOFMARS

print "SYSTEM.ADMIN.SSL on VENUS" | tee -a ${0##*/}.$TimeStamp.out 
runmqsc VENUS  >>${0##*/}.$TimeStamp.out << EOFVENUS 2>&1
DEFINE CHANNEL('SYSTEM.ADMIN.SSL') CHLTYPE(SVRCONN) TRPTYPE(TCP) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA)  SSLCAUTH(REQUIRED) REPLACE
REFRESH SECURITY TYPE(SSL)
ALTER QMGR CHLAUTH(DISABLED)
EOFVENUS

print "\n${0##*/} done.  Output log saved to   ${0##*/}.$TimeStamp.out\n"

# End of script
exit 1
