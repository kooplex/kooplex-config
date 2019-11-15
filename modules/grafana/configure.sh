#!/bin/bash

RF=$BUILDDIR/grafana

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


###
# Setup grafana to receive data from prometheus
# Add datasource prometheus
# http://kooplex-test.elte.hu:9090
# or
# http://kooplex-test.elte.hu/prometheus

case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-grafana..."

      SRV_GRAFANA=$SRV/_grafana
      mkdir -p $SRV_GRAFANA/etc $SRV_GRAFANA/log $SRV_GRAFANA/varlib $SRV_GRAFANA/etc $SRV_GRAFANA/dashboards $SRV_GRAFANA/datasources $SRV_GRAFANA/notifiers

      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/dashboards -o o=bind ${PREFIX}-grafana-dashboards
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/datasources -o o=bind ${PREFIX}-grafana-datasources
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/varlib -o o=bind ${PREFIX}-grafana-varlib
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/log -o o=bind ${PREFIX}-grafana-log
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/etc -o o=bind ${PREFIX}-grafana-etc
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/notifiers -o o=bind ${PREFIX}-grafana-notifiers

#      cp Dockerfile $RF
#      sed -e "s/##PREFIX##/$PREFIX/" \
#          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" etc/grafana.yml-template > $SRV_GRAFANA/etc/grafana.yml
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##SRV_GRAFANA##/$(replace_slash ${SRV_GRAFANA})/" \
          -e "s/##ADMIN_PW##/$DUMMYPASS/" \
	  -e "s/##OUTERHOST##/$OUTERHOST/"\
	  -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-grafana..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting grafana ${PREFIX}-grafana"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting grafana ${PREFIX}-grafana"
    docker $DOCKERARGS restart $PREFIX-grafana
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping grafana ${PREFIX}-grafana"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing grafana ${PREFIX}-grafana"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging grafana ${PREFIX}-grafana"
    rm -R $RF
  ;;
    
esac
