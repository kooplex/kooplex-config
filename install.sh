#!/bin/bash

# Init script

source ./lib.sh

# Primary setup

mkdir -p $SRV
mkdir -p $SECRETS

# Install services

# TODO: install admin docker

svcs=$(getservices "$@")

for svc in $svcs
do
  echo "Installing $PROJECT-$svc"
  cd $svc
  . ./install.sh
  cd ..
done

echo "Install complete"