#!/bin/bash

(( EUID == 0 )) || { echo "Script must be run as root." ; exit 1 ; }

: ${WORKDIR:=work} ; export WORKDIR
: ${BLOCKCOUNT:=1998} ; export BLOCKCOUNT
: ${BLOCKSIZE:=1M} ; export BLOCKSIZE
: ${SPLIT:=64} ; export SPLIT
: ${HOSTNAME_:=alarmpi} ; export HOSTNAME_

./make-alarmpi-image -e -f -6 $*

