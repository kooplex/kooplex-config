#!/bin/bash

case $VERB in
  "build")
    echo "Installing network $PREFIX-net [$SUBNET]"
  
    if docker  $DOCKERARGS network ls | grep " $PREFIX-net"; then 
     echo "$PREFIX-net exists, moving on..."
    else
     docker $DOCKERARGS network create \
      --driver bridge \
      --subnet $SUBNET $PREFIX-net
   fi
  ;;
  "start")
    
  ;;
  "init")
    
  ;;
  "stop")
    
  ;;
  "remove")
    echo "Removing network $PREFIX-net [$SUBNET]"
    docker $DOCKERARGS network rm $PREFIX-net
  ;;
  "purge")

  ;;
esac