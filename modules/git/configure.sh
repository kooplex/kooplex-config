#!/bin/bash

RF=$BUILDDIR/git

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-git..."
      sed -e "s/##PREFIX##/$PREFIX/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
      sed -i -e "s/##PROJECT##/$PROJECT/" $DOCKER_COMPOSE_FILE
      cp Dockerfile $RF
      cp scripts/start.sh $RF
      cp scripts/init-ssh-agent.sh $RF
      cp etc/nsswitch.conf $RF
#FIXME: sed from template, or use lib
      cp etc/nslcd.conf $RF

      echo "2. Building ${PREFIX}-git..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")  
      echo "Starting container ${PREFIX}-git"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "init")  
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-git"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
    echo "Removing $RF" 
    rm -R -f $RF
  ;;

  "clean")
  ;;
esac

