#!/bin/bash

MYPWD=$PWD
CONFIGDIR=$(dirname $0)

for SRC in $CONFIGDIR/config.sh $CONFIGDIR/lib.sh ; do
    if [ ! -f $SRC ] ; then
        echo "$SRC is missing" >&2
        exit 1
    fi
    . $SRC
done


echo "Prefix $PREFIX" >&2

VERB=$1
shift

if [ "$1" = "notebook" ]; then
  SVCS=$1
  EXTRA=$2
elif [ "$1" = "all" ] ; then
  SVCS="$SYSMODULES $MODULES"
elif [ "$1" = "sys" ] ; then
  SVCS="$SYSMODULES"
else
  SVCS="$@"
fi

echo "Command $VERB" >&2
echo "Modules $SVCS" >&2
echo "Extra $EXTRA" >&2
 
case $VERB in
  "createvolumes")
    echo "Checking persistent volumes for services" >&2
    volume_configuration
    kubectl apply -f $CONF_YAML
  ;;
  "starthelper")
    echo "Starting helper pod" >&2
    start_helper
  ;;
  "stophelper")
    echo "Stopping helper pod" >&2
    stop_helper
  ;;
  "removevolumes")
    echo "Remove persistent volumes for services" >&2
    volume_configuration
    kubectl delete -f $CONF_YAML
  ;;
  "build"|"install"|"start"|"uninstall"|"init"|"stop"|"remove"|"purge")
    set -e
  ;;
  "restart")
    $0 stop $@
    $0 start $@
  ;;
  *)
    echo "Unknown command $VERB" >&2
    exit 1
  ;;
esac

echo "Issue $VERB for each module..." >&2

for MODULE_NAME in $SVCS
do
  mkdir_build
  cd $CONFIGDIR/modules/$MODULE_NAME
  . ./configure.sh
done

cd $MYPWD
echo "Finished $VERB." >&2
