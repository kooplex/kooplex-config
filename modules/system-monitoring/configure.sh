#!/bin/bash
MODULE_NAME=system-monitoring
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

SRV_GRAFANA=$SRV/_grafana
SRV_PROMETHEUS=$SRV/_prometheus
SRV_NODEEXPORTER=$SRV/_nodeexporter

###
# Setup grafana to receive data from prometheus
# Add datasource prometheus
# http://kooplex-test-prometheus:9090
# Them import dashboard
# https://grafana.com/grafana/dashboards/893

case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-grafana..."

      mkdir -p $SRV_GRAFANA/etc $SRV_GRAFANA/log $SRV_GRAFANA/varlib $SRV_GRAFANA/etc $SRV_GRAFANA/dashboards $SRV_GRAFANA/datasources $SRV_GRAFANA/notifiers
      mkdir -p $SRV_PROMETHEUS/etc $SRV_PROMETHEUS/log $SRV_PROMETHEUS/data
      mkdir -p $SRV_NODEEXPORTER/etc

      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/dashboards -o o=bind ${PREFIX}-grafana-dashboards
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/datasources -o o=bind ${PREFIX}-grafana-datasources
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/varlib -o o=bind ${PREFIX}-grafana-varlib
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/log -o o=bind ${PREFIX}-grafana-log
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/etc -o o=bind ${PREFIX}-grafana-etc
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_GRAFANA/notifiers -o o=bind ${PREFIX}-grafana-notifiers
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_PROMETHEUS/data -o o=bind ${PREFIX}-prometheus-data
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_PROMETHEUS/log -o o=bind ${PREFIX}-prometheus-log
      docker $DOCKERARGS volume create -o type=none -o device=$SRV_NODEEXPORTER/etc -o o=bind ${PREFIX}-node-exporter-etc

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##SRV_GRAFANA##/$(replace_slash ${SRV_GRAFANA})/" \
          -e "s/##ADMIN_PW##/$DUMMYPASS/" \
	  -e "s/##OUTERHOST##/$OUTERHOST/"\
	  -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##SRV_PROMETHEUS##/$(replace_slash ${SRV_PROMETHEUS})/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" etc/prometheus.yml-template > $SRV_PROMETHEUS/etc/prometheus.yml
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" etc/grafana.ini-template > $SRV_GRAFANA/etc/grafana.ini

      echo "2. Building ${PREFIX}-grafana..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
    # OUTER-NGINX
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-${MODULE_NAME}-template > $CONF_DIR/outer_nginx/sites-enabled/${MODULE_NAME}

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
