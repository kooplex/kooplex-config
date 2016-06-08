#!/bin/bash

source ./lib.sh

svcs=$(getservices "$@")
svcs=$(reverse "$svcs")

for svc in $svcs
do
  echo "Removing $PROJECT-$svc"
  cd $svc
  . ./remove.sh
  cd ..
done

