#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-occ"
    docker $DOCKERARGS build -t kooplex-occ .
  ;;
  "install")
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
    echo "Cleaning base image kooplex-occ"
    docker $DOCKERARGS rmi kooplex-occ
  ;;
esac
