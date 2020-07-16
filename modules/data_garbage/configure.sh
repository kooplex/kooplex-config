#!/bin/bash

MODULE_NAME=garbage

case $VERB in
  "build")
      echo "1. Building ${MODULE_NAME}..."
      
      mkdir -p  $SRV/_hub.garbage
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hub.garbage -o o=bind ${PREFIX}-garbage

  ;;

  "purge")
      docker $DOCKERARGS volume rm ${PREFIX}-garbage
  ;;

  "cleandata")
    rm -r $SRV/_hub.garbage
  ;;


esac

