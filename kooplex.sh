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