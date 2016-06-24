#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-admin"
    
    docker $DOCKERARGS build -t kooplex-admin .
  ;;
  "install")
  
    docker $DOCKERARGS create \
      --name $PROJECT-admin \
      --hostname $PROJECT-admin \
      --net $PROJECT-net \
      --ip $ADMINIP \
      --privileged \
      kooplex-admin
  ;;
  "start")
    echo "Starting admin $PROJECT-admin [$ADMINIP]"
    docker $DOCKERARGS start $PROJECT-admin
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping admin $PROJECT-admin [$ADMINIP]"
    docker $DOCKERARGS stop $PROJECT-admin
  ;;
  "remove")
    echo "Removing admin $PROJECT-admin [$ADMINIP]"
    docker $DOCKERARGS rm $PROJECT-admin
  ;;
  "purge")
  ;;
  "clean")
    echo "Cleaning admin image kooplex-admin"
    docker $DOCKERARGS rmi kooplex-admin
  ;;
esac