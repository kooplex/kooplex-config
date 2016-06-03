#!/bin/bash

ROOT=$1
PROJECT=$2

SRV=$ROOT/$PROJECT/srv
SECRETS=$SRV/.secrets

cd nginx
. ./remove.sh
cd ..

docker network rm $PROJECT-net

rm -R $SRV