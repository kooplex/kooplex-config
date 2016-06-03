#!/bin/bash

# Init script

ROOT=$1
PROJECT=$2
SUBNET=$3
DUMMYPASS=$4

SRV=$ROOT/$PROJECT/srv
SECRETS=$SRV/.secrets

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
#cd ldap
#./init.sh
#cd ..

