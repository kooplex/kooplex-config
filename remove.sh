#!/bin/bash

source ./config.sh

ROOT=$1

SRV=$ROOT/$PROJECT/srv

cd home
. ./remove.sh
cd ..

cd ldap
. ./remove.sh
cd ..

cd nginx
. ./remove.sh
cd ..

docker network rm $PROJECT-net

rm -R $SRV