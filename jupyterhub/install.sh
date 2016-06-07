#!/bin/bash

echo "Installing jupyterhub $PROJECT-jupyterhub [$JUPYTERHUBIP]"

# Initialize jupyterhub directories and prepare config files

mkdir -p $SRV/jupyterhub
mkdir -p $SRV/jupyterhub/etc
cp etc/nsswitch.conf $SRV/jupyterhub/etc

# Prepare config file

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
" > $SRV/jupyterhub/etc/nslcd.conf

chmod 0600 $SRV/jupyterhub/etc/nslcd.conf

# Install and execute docker image

docker build -t jupyterhub-compare .

docker run -d \
  --name $PROJECT-jupyterhub \
  --net $PROJECT-net \
  --ip $JUPYTERHUBIP \
  -v $SRV/jupyterhub:/srv/jupyterhub \
  -v $SRV/jupyterhub/etc/nslcd.conf:/etc/nslcd.conf:ro \
  -v $SRV/jupyterhub/etc/nsswitch.conf:/etc/nsswitch.conf:ro \
  jupyterhub-compare

