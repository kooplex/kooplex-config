#!/bin/bash

source ./lib.sh
VERB=$1
SVCS=$(getmodules "$@")

echo "Starting $VERB..."

for svc in $SVCS
do
  cd modules/$svc
  . ./configure.sh
  cd ../..
done

echo "Finished $VERB."