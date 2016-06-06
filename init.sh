#!/bin/bash

# Init script

source ./lib.sh

# Initialize services

for svc in ldap home gitlab nginx
do
  cd $svc
  . ./init.sh
  cd ..
done

echo "Initialize complete"