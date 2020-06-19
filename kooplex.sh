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
echo "Checking persistent volumes for services" >&2
create_pv
create_pvc

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

  "build"|"install"|"start"|"init"|"stop"|"remove"|"purge")
    set -e
  ;;
  *)
    echo "Unknown command $VERB" >&2
    exit 1
  ;;
esac

echo "Starting $VERB..." >&2

for MODULE_NAME in $SVCS
do
  mkdir_build
  cd $CONFIGDIR/modules/$MODULE_NAME
  . ./configure.sh
done

cd $MYPWD
echo "Finished $VERB." >&2
