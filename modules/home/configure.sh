#!/bin/bash

case $VERB in
  "install")
    echo "Installing nfs home $PROJECT-home [$HOMEIP]"
    
    mkdir -p $SRV/home
    
    docker $DOCKERARGS create \
      --name $PROJECT-home \
      --hostname $PROJECT-home \
      --net $PROJECT-net \
      --ip $HOMEIP \
      --privileged \
      -v $SRV/home:/home \
      cpuguy83/nfs-server /home  ;;
  "start")
    echo "Starting nfs home $PROJECT-home [$HOMEIP]"
    docker $DOCKERARGS start $PROJECT-home
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping nfs home $PROJECT-home [$HOMEIP]"
    docker $DOCKERARGS stop $PROJECT-home
  ;;
  "remove")
    echo "Removing nfs home $PROJECT-home [$HOMEIP]"
    docker $DOCKERARGS rm $PROJECT-home
  ;;
  "purge")
    echo "Purging nfs home $PROJECT-home [$HOMEIP]"
    mkdir -p $SRV/home
  ;;
esac