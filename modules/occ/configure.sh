#!/bin/bash

case $VERB in
  "build")
    echo "Building image $PREFIX-occ"
    docker $DOCKERARGS build -t $PREFIX-occ .
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
    echo "Cleaning base image $PREFIX-occ"
    docker $DOCKERARGS rmi $PREFIX-occ
  ;;
esac
