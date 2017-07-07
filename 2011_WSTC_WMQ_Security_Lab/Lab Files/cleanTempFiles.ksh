#!/usr/bin/ksh
cd "$(cd "$(dirname "$0")"; pwd)"

find . -name '*~'    | xargs -I{} rm {}
find . -name '*.out' | xargs -I{} rm {}

rm -f /var/mqm/exits/* >/dev/null 2>&1

