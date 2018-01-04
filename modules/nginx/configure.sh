#!/bin/bash

RF=$BUILDDIR/nginx

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-impersonator..."

      cp Dockerfile $RF
      cp etc/nginx.conf $RF
      sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERHOSTNAME##/$OUTERHOSTNAME/" \
          -e "s/##INNERHOST##/$INNERHOST/" etc/sites.conf > $RF/sites.conf
      
      sed -e "s/##PREFIX##/$PREFIX/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-nginx..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting nginx ${PREFIX}-nginx"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting nginx ${PREFIX}-nginx"
    docker $DOCKERARGS restart $PREFIX-nginx
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping nginx ${PREFIX}-nginx"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing nginx ${PREFIX}-net"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging nginx ${PREFIX}-nginx"
    rm -R $RF
  ;;
    
esac
