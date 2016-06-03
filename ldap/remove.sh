#!/bin/bash

docker stop $PROJECT-ldap
docker rm $PROJECT-ldap

rm -R $SRV/ldap