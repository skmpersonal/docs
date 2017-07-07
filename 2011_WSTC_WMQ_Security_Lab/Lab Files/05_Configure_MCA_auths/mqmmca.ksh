#!/usr/bin/ksh

runmqsc VENUS < ./mqmmca_VENUS.mqs

echo "STOP CHL(MARS.VENUS) STATUS(INACTIVE)" | runmqsc MARS
sleep 3
echo "START CHL(MARS.VENUS)" | runmqsc MARS
