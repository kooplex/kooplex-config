#!/bin/bash

CONFIGDIR=$PWD

. ./lib.sh

getmodules() {
  if [ $# -lt 2 ] || [ "$2" = "all" ]; then
    echo "$SYSMODULES $MODULES"
  elif [ "$2" = "sys" ]; then
    echo "$SYSMODULES"
  else
    local args=($@)
    echo "${args[@]:1}"
  fi
}

VERB=$1
SVCS=$2
if [ "$SVCS" = "notebook" ]; then
  EXTRA=$3
else
  SVCS=$(getmodules "$@")
fi
echo $VERB
mkdir -p $BUILDDIR

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
