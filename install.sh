#!/bin/bash

# Init script

source ./lib.sh

# Primary setup

mkdir -p $SRV
mkdir -p $SECRETS

# Initialize docker network
echo Creating docker network $PROJECT-net [$SUBNET]

docker network create --driver bridge --subnet $SUBNET $PROJECT-net

# Install services

# TODO: install admin docker

for svc in ldap home gitlab nginx
do
  cd $svc
  . ./install.sh
  cd ..
done

echo "Install complete"