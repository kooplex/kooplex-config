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
mkdir -p $BUILDDIR


CA_DIR=$BUILDDIR/CA
if [ -d $CA_DIR ] ; then
  #  echo "$CA_DIR already present; will not generate ca" >&2
    echo ""
else 
    echo "generate CA"
    set -e
    mkdir $CA_DIR
    openssl genrsa -out $CA_DIR/rootCA.key 4096
    openssl req -x509 -new -nodes -key $CA_DIR/rootCA.key -sha256 -days 1024 -subj "/C=HU/ST=BP/L=Budapest/O=KRFT/CN=$OUTERHOST" -out $CA_DIR/rootCA.crt
fi

case $VERB in

  "build")
    set -e
  ;;
  "install")
    set -e
  ;;
  "install-nginx")
    set -e
  ;;
  "install-hydra")
    set -e
  ;;
  "start")

    set -e
  ;;
  "init")
    set -e
  ;;
esac


for svc in $SVCS
do

  echo "Starting $VERB $svc"
  cd modules/$svc
  . ./configure.sh
  cd $CONFIGDIR
  echo "Finished $VERB $svc"

done

