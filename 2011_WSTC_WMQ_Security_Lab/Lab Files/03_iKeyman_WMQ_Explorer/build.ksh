#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

# Run build scripts from all prior modules
../02_SSL_Wizard_QMgr_Chls/build.ksh
./01_Personal_Keystore.ksh
