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
    
   if docker  $DOCKERARGS network ls | grep " $PREFIX-service-net"; then 
     echo "$PREFIX-service-net exists, moving on..."
    else
     docker $DOCKERARGS network create \
      --driver bridge \
      --subnet $SERVICESUBNET $PREFIX-service-net
   fi

   if docker  $DOCKERARGS network ls | grep " $PREFIX-monitoring-net"; then 
     echo "$PREFIX-monitoring-net exists, moving on..."
    else
     docker $DOCKERARGS network create \
      --driver bridge \
      --subnet $MONITORINGSUBNET $PREFIX-monitoring-net
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
    docker $DOCKERARGS network rm $PREFIX-service-net
    docker $DOCKERARGS network rm $PREFIX-monitoring-net
  ;;
  "purge")

  ;;
esac
