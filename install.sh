#!/bin/bash

# Init script

source ./config.sh

ROOT=$1
IMG=0
SRV=$ROOT/$PROJECT/srv
SECRETS=$SRV/.secrets

LDAPORG="dc=$PROJECT,dc=vo,dc=elte,dc=hu"

# Primary setup

mkdir -p $SRV
mkdir -p $SECRETS

# Initialize docker network
echo Creating docker network $PROJECT-net [$SUBNET]

docker network create --driver bridge --subnet $SUBNET $PROJECT-net

# 1. NGINX

IP=`./ipadd.sh "$SUBNET" 2`

cd nginx
. ./install.sh $IP
cd ..

# 2. LDAP

IP=`./ipadd.sh "$SUBNET" 3`

cd ldap
. ./install.sh $IP $DOMAIN
cd ..

