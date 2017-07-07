#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

# Run build scripts from all prior modules
../01_Introduction/build.ksh
./01_SSL_Channels.ksh
