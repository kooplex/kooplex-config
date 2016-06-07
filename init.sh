#!/bin/bash

# Init script

source ./lib.sh

# Initialize services

svcs=$(getservices "$@")

for svc in $svcs
do
  echo "Initializing $PROJECT-$svc"
  cd $svc
  . ./init.sh
  cd ..
done

echo "Initialize complete"