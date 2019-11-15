#!/bin/bash

RF=$BUILDDIR/cadvisor

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-cadvisor..."


#      cp Dockerfile $RF
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-cadvisor..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting cadvisor ${PREFIX}-cadvisor"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting cadvisor ${PREFIX}-cadvisor"
    docker $DOCKERARGS restart $PREFIX-cadvisor
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping cadvisor ${PREFIX}-cadvisor"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing cadvisor ${PREFIX}-cadvisor"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging cadvisor ${PREFIX}-cadvisor"
    rm -R $RF
  ;;
    
esac
