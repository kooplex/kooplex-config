#!/bin/bash

source ./config.sh

SRV=$ROOT/$PROJECT/srv

cd gitlab
. ./remove.sh
cd ..

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