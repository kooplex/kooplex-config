#!/bin/bash

RF=$BUILDDIR/prometheus

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-prometheus..."

      SRV_PROMETHEUS=$SRV/_prometheus
      mkdir -p $SRV_PROMETHEUS/etc $SRV_PROMETHEUS/log $SRV_PROMETHEUS/data

      docker $DOCKERARGS volume create -o type=none -o device=$SRV_PROMETHEUS/data -o o=bind ${PREFIX}-prometheus-data
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_PROMETHEUS/log -o o=bind ${PREFIX}-prometheus-log

#      cp Dockerfile $RF
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" etc/prometheus.yml-template > $SRV_PROMETHEUS/etc/prometheus.yml
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##SRV_PROMETHEUS##/$(replace_slash ${SRV_PROMETHEUS})/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-prometheus..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting prometheus ${PREFIX}-prometheus"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting prometheus ${PREFIX}-prometheus"
    docker $DOCKERARGS restart $PREFIX-prometheus
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping prometheus ${PREFIX}-prometheus"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing prometheus ${PREFIX}-prometheus"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging prometheus ${PREFIX}-prometheus"
    rm -R $RF
  ;;
    
esac
