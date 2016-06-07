#!/bin/bash

# Init script

source ./lib.sh

# Primary setup

mkdir -p $SRV
mkdir -p $SECRETS

for svc in ldap home gitlab nginx jupyterhub
do
  cd $svc
  . ./install.sh
  cd ..
done

echo "Install complete"