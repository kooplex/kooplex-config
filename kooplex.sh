#!/bin/bash

CONFIGDIR=$PWD

. ./lib.sh

VERB=$(getverb "$@")
SVCS=$(getmodules "$@")

case $VERB in
  "build")
    set -e
  ;;
  "install")
    set -e
  ;;
  "start")
    if ! grep -qs "$SRV" /proc/mounts; then    
      echo "Mount $SRV does not exist! FATAL ERROR"
      return -1
    fi

    set -e
  ;;
  "init")
    set -e
  ;;
esac

echo "Starting $VERB..."

for svc in $SVCS
do
  cd modules/$svc
  . ./configure.sh
  cd $CONFIGDIR
done

echo "Finished $VERB."