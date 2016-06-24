#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"
    
    mkdir -p $SRV
    mkdir -p $SECRETS
    
    docker $DOCKERARGS build -t kooplex-base  .
  ;;
  "start")
    
  ;;
  "init")
    
  ;;
  "stop")
    
  ;;
  "remove")

  ;;
  "purge")
    echo "Purging base image kooplex-base"
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac