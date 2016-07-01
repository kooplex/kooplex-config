#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-keystone"
    docker $DOCKERARGS build -t kooplex-keystone  .
  ;;
  "install")
    echo "Installing keystone $PROJECT-keystone [$KEYSTONEIP]"
    
    mkdir -p $SRV/keystone/etc
    
    docker $DOCKERARGS create \
      --name $PROJECT-keystone \
      --hostname $PROJECT-keystone \
      --net $PROJECT-net \
      --ip $KEYSTONEIP \
      -v $SRV/keystone/etc/keystone.conf:/etc/keystone/keystone.conf \
      kooplex-keystone
  ;;
  "start")
    echo "Starting keystone kooplex-keystone"
    docker $DOCKERARGS start $PROJECT-keystone
  ;;
  "init")
  ;;
  "stop")
    echo "Stopping keystone $PROJECT-keystone [$KEYSTONEIP]"
    docker $DOCKERARGS stop $PROJECT-keystone
  ;;
  "remove")
    echo "Removing keystone $PROJECT-keystone [$KEYSTONEIP]"
    docker $DOCKERARGS rm $PROJECT-keystone
  ;;
  "purge")
    echo "Purging keystone $PROJECT-keystone [$KEYSTONEIP]"
    rm -R -f $SRV/keystone
  ;;
  "clean")
    echo "Installing image kooplex-keystone"
    docker $DOCKERARGS rmi kooplex-keystone
  ;;
esac