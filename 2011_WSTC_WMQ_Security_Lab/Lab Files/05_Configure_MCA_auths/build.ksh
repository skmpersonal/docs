#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

# Run build scripts from all prior modules
../04_Fine_grained_authentication/build.ksh

./mqmmca.ksh
./mqmmqi.ksh VENUS
