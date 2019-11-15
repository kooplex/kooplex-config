#!/bin/bash

RF=$BUILDDIR/node-exporter

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml
SRV_NODEEXPORTER=$SRV/_nodeexporter

case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-node-exporter..."

      mkdir -p $SRV_NODEEXPORTER/etc

      docker $DOCKERARGS volume create -o type=none -o device=$SRV_NODEEXPORTER/etc -o o=bind ${PREFIX}-node-exporter-etc

#      cp Dockerfile $RF
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-node-exporter..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting node-exporter ${PREFIX}-node-exporter"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting node-exporter ${PREFIX}-node-exporter"
    docker $DOCKERARGS restart $PREFIX-node-exporter
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping node-exporter ${PREFIX}-node-exporter"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing node-exporter ${PREFIX}-node-exporter"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging node-exporter ${PREFIX}-node-exporter"
    rm -R $RF
  ;;
    
esac
