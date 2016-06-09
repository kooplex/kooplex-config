#!/bin/bash

echo "Installing owncloud $PROJECT-owncloud [$OWNCLOUDIP]"

# Initialize owncloud directories and preparing config files

mkdir -p $SRV/owncloud/etc
mkdir -p $SRV/owncloud/apps
mkdir -p $SRV/owncloud/config
mkdir -p $SRV/owncloud/data

# Prepare config files

echo "$(ldap_getconfig)" > etc/nslcd.conf

# Install and execute docker image

docker build -t $PROJECT-owncloud --no-cache=true .

rm etc/nslcd.conf

docker run -d \
  --name $PROJECT-owncloud \
  --hostname $PROJECT-owncloud \
  --net $PROJECT-net \
  --ip $OWNCLOUDIP \
  -v $SRV/owncloud/apps:/var/www/html/apps \
  -v $SRV/owncloud/config:/var/www/html/config \
  -v $SRV/owncloud/data:/var/www/html/data \
  $PROJECT-owncloud

