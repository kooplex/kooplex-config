#!/bin/bash

RF=$BUILDDIR/kubernetes

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-impersonator..."

    if [ $REWRITEPROTO = "http" ]; then
      EXTRACONFIG="ports:\n      - 80:80"
    fi

      cp Dockerfile $RF
      cp etc/kubernetes.conf $RF
      sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERHOSTNAME##/$OUTERHOSTNAME/" \
          -e "s/##INNERHOST##/$INNERHOST/" etc/sites.conf > $RF/sites.conf
      
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-kubernetes..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting kubernetes ${PREFIX}-kubernetes"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting kubernetes ${PREFIX}-kubernetes"
    docker $DOCKERARGS restart $PREFIX-kubernetes
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping kubernetes ${PREFIX}-kubernetes"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing kubernetes ${PREFIX}-net"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging kubernetes ${PREFIX}-kubernetes"
    rm -R $RF
  ;;
    
esac
