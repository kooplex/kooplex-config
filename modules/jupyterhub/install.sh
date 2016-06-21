#!/bin/bash

echo "Installing jupyterhub $PROJECT-jupyterhub [$JUPYTERHUBIP]"

# Initialize jupyterhub directories and prepare config files

mkdir -p $SRV/jupyterhub
mkdir -p $SRV/jupyterhub/etc

# Prepare config files

echo "$(ldap_getconfig)" > etc/nslcd.conf

# Install and execute docker image

docker build -t $PROJECT-jupyterhub --no-cache=true .

docker run -d \
  --name $PROJECT-jupyterhub \
  --hostname $PROJECT-jupyterhub \
  --net $PROJECT-net \
  --ip $JUPYTERHUBIP \
  -e "GITLAB_HOST=http://$DOMAIN/gitlab" \
  -v $SRV/jupyterhub:/srv/jupyterhub \
  $PROJECT-jupyterhub

