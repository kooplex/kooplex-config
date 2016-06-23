#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"
    
    cpetc
    docker $DOCKERARGS build -t kooplex-base  .
    rmetc
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