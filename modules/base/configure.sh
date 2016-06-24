#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"
    
    mkdir -p $SRV
    mkdir -p $SECRETS
    
    docker $DOCKERARGS build -t kooplex-base  .
  ;;
  "install")
  echo "Generating secrets..."
    LDAPPASS=$(createsecret ldap)
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

  ;;
  "clean")
    echo "Cleaning base image kooplex-base"
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac