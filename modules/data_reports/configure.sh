#!/bin/bash

MODULE_NAME=reports

case $VERB in
  "build")
      echo "1. Building ${MODULE_NAME}..."
      
      mkdir -p $SRV/_report 
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_report -o o=bind ${PREFIX}-report
  ;;

  "purge")
      
      docker $DOCKERARGS volume rm ${PREFIX}-report
  ;;

  "cleandata")
    rm -r $SRV/_report
  ;;


esac

