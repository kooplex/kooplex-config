#!/bin/bash

source ./lib.sh

for svc in jupyterhub gitlab home ldap nginx 
do
  cd $svc
  . ./remove.sh
  cd ..
done

docker network rm $PROJECT-net

rm -R $SRV