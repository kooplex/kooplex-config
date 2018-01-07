#!/bin/bash

case $VERB in
  "build")
    echo "Installing network $PROJECT-net [$SUBNET]"
  
    if docker  $DOCKERARGS network ls | grep " $PROJECT-net"; then 
     echo "$PROJECT-net exists, moving on..."
    else
     docker $DOCKERARGS network create \
      --driver bridge \
      --subnet $SUBNET $PROJECT-net
   fi
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