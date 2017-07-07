#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

# Run build scripts from all prior modules
../03_iKeyman_WMQ_Explorer/build.ksh
./01_Set_CHLAUTH.ksh
