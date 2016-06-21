#!/bin/bash

# Init script

source ./lib.sh

# Primary setup

mkdir -p $SRV
mkdir -p $SECRETS

svcs=$(getservices "$@")

for svc in $svcs
do
  echo "Installing $PROJECT-$svc"
  cd modules/$svc
  . ./install.sh
  cd ../..
done

echo "Install complete"