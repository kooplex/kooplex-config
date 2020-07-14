#!/bin/bash

MODULE_NAME=homes

case $VERB in
  "build")
      echo "1. Building ${MODULE_NAME}..."
      
      mkdir -p $SRV/home
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/home -o o=bind ${PREFIX}-home

  ;;

  "purge")
      
      docker $DOCKERARGS volume rm ${PREFIX}-home
  ;;


esac

