#!/bin/bash

MODULE_NAME=share

case $VERB in
  "build")
      echo "1. Building ${MODULE_NAME}..."
      
      mkdir -p  $SRV/_share
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_share -o o=bind ${PREFIX}-share

  ;;

  "purge")
      
      docker $DOCKERARGS volume rm ${PREFIX}-share
  ;;

  "clean")
    rm -r $SRV/_share
  ;;

esac

