#!/bin/bash

case $VERB in
  "install")
    echo "Installing network $PROJECT-net [$SUBNET]"
    docker $DOCKERARGS network create \
      --driver bridge \
      --subnet $SUBNET $PROJECT-net
  ;;
  "start")
    
  ;;
  "init")
    
  ;;
  "stop")
    
  ;;
  "remove")
    echo "Removing network $PROJECT-net [$SUBNET]"
    docker $DOCKERARGS network rm $PROJECT-net
  ;;
  "purge")

  ;;
esac