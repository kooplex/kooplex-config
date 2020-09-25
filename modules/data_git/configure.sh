#!/bin/bash

MODULE_NAME=git

case $VERB in
  "build")
      echo "1. Building ${MODULE_NAME}..."
      
      mkdir -p  $SRV/_git 
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_git -o o=bind ${PREFIX}-git

  ;;

  "purge")
      
      docker $DOCKERARGS volume rm ${PREFIX}-git
  ;;

  "clean")
    rm -r $SRV/_git
  ;;


esac

