#!/bin/bash

# Init script

source ./lib.sh
source ./config.sh

LDAPORG="dc=$PROJECT,dc=vo,dc=elte,dc=hu"

# Primary setup

mkdir -p $SRV
mkdir -p $SECRETS

# Initialize docker network
echo Creating docker network $PROJECT-net [$SUBNET]

docker network create --driver bridge --subnet $SUBNET $PROJECT-net

# TODO: install admin docker

cd ldap
. ./install.sh
cd ..

cd home
. ./install.sh
cd ..

cd gitlab
. ./install.sh
cd ..

cd nginx
. ./install.sh
cd ..

echo "Install complete"