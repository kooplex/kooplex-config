#!/bin/bash

RF=$BUILDDIR/monitor
mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "Building image $PREFIX-monitor"

    mkdir -p $SRV/_monitordb
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_monitordb -o o=bind ${PREFIX}-monitordb
    cp scripts/* $RF
    cp etc/* $RF
    cp Dockerfile.monitordb $RF
    
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##POSTGRESDBPW##/$GITLABDBPW/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

    docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    
  ;;
  "install")

  ;;
  "start")
     echo "Start monitoring $PROJECT-monitor [$MONITORIP]"
     docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-monitordb
     #FIXME
     echo "Manually start cron and import scheme!!!!!!!!!!!!"
  ;;
  "init")
     docker exec ${PREFIX}-monitordb bash -c /etc/monitordb/create_scheme.sh
  
  ;;
  "stop")
      echo "Stop monitoring $PROJECT-monitor [$MONITORIP]"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down  
      
  ;;    
  "remove")
      echo "Remove monitoring container $PROJECT-monitor [$MONITORIP]"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
  "purge")
      echo "Purge datafiles gathered by  monitoring $PROJECT-monitor [$MONITORIP]"
      docker $DOCKERARGS start $PROJECT-monitordb

  ;;
  "clean")
    echo "Cleaning base image $PREFIX-monitor"
    docker $DOCKERARGS volume rm ${PREFIX}-monitordb 
   
    ;;
esac
