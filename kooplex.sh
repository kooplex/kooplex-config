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
  "CA")
    CA_DIR=$BUILDDIR/CA
    if [ -d $CA_DIR ] ; then
        echo "$CA_DIR already present; will not generate ca" >&2
        exit 1
    fi
    set -e
    mkdir $CA_DIR
    openssl genrsa -out $CA_DIR/rootCA.key 4096
    openssl req -x509 -new -nodes -key $CA_DIR/rootCA.key -sha256 -days 1024 -subj "/C=HU/ST=BP/L=Budapest/O=KRFT/CN=$OUTERHOST" -out $CA_DIR/rootCA.crt
    exit 0
  ;;

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
