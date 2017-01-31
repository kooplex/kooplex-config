#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"   
    docker $DOCKERARGS build -t kooplex-base .
  ;;
  "install")
	# Generate secrets here so they can be modified prior to
	# installing other modules
    echo "Generating secrets..."
    createsecret ldap > /dev/null
    createsecret mysql > /dev/null
	createsecret gitlab > /dev/null
	createsecret sshkey > /dev/null
	createsecret proxy > /dev/null
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
    echo "Removing secrets $SRV/"
    rm -r $SRV/.secrets
  ;;
  "clean")
    echo "Cleaning base image kooplex-base"
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac
