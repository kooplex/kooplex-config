#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-nextcloud"
    
    cpetc
    docker $DOCKERARGS build -t kooplex-nextcloud .
    rmetc
  ;;
  "install")
    echo "Installing nextcloud $PROJECT-nextcloud [$NEXTCLOUDIP]"
    
    cpetc
    
    mkdir -p $SRV/var/www/html
    
    docker $DOCKERARGS create \
      --name $PROJECT-nextcloud \
      --hostname $PROJECT-nextcloud \
      --net $PROJECT-net \
      --ip $NEXTCLOUDIP \
      --privileged \
      -v $SRV/nextcloud/var/www/html:/var/www/html \
      kluck/nextcloud
    
    rmetc
  ;;
  "start")
    echo "Starting nextcloud $PROJECT-nextcloud [$NEXTCLOUDIP]"
    docker $DOCKERARGS start $PROJECT-nextcloud
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping nextcloud $PROJECT-nextcloud [$NEXTCLOUDIP]"
    docker $DOCKERARGS stop $PROJECT-nextcloud
  ;;
  "remove")
    echo "Removing nextcloud $PROJECT-nextcloud [$NEXTCLOUDIP]"
    docker $DOCKERARGS rm $PROJECT-nextcloud
  ;;
  "purge")
    echo "Purging nextcloud $PROJECT-nextcloud [$NEXTCLOUDIP]"
    rm -R $SRV/nextcloud
    echo "Purging base image kooplex-nextcloud"
    docker $DOCKERARGS rmi kooplex-nextcloud
  ;;
esac