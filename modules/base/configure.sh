#!/bin/bash

case $VERB in
  "install")
    echo "Installing base image kooplex-base"
    
    mkdir etc
    cp -R ../../etc/* etc/
    
    docker $DOCKERARGS build -t kooplex-base  .
    
    rm -R etc
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