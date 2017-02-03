#!/bin/bash

case $VERB in
  "install")
    
    docker $DOCKERARGS create \
      --name $PROJECT-home \
      --hostname $PROJECT-home \
      --net $PROJECT-net \
      --ip $HOMEIP \
      -v $SRV/home:/home \
      --privileged \
      kooplex-base
 
  ;;
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
    rm -R $SRV/home
  ;;
esac