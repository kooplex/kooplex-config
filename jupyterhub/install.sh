#!/bin/bash

echo "Installing jupyterhub $PROJECT-jupyterhub [$JUPYTERHUBIP]"

# Initialize jupyterhub directories and prepare config files

mkdir -p $SRV/jupyterhub

# Prepare config files

echo "
uid nslcd
gid nslcd

uri ldap://$PROJECT-ldap/

base $LDAPORG
scope subtree

binddn cn=admin,$LDAPORG
bindpw $LDAPPASS
rootpwmoddn cn=admin,$LDAPORG
rootpwmodpw $LDAPPASS
" > etc/nslcd.conf

# Install and execute docker image

docker build -t jupyterhub-compare .

rm etc/nslcd.conf

docker run -d \
  --name $PROJECT-jupyterhub \
  --net $PROJECT-net \
  --ip $JUPYTERHUBIP \
  -v $SRV/jupyterhub:/srv/jupyterhub \
  jupyterhub-compare

