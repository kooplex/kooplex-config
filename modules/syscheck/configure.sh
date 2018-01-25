#!/bin/bash

RF=$BUILDDIR/syscheck

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


PROJECTDB=$PROJECT"_kooplex"

case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-proxy..."

      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-template > $RF/Dockerfile
      cp scripts/syscheck.py $RF
      cp etc/crontab $RF
      
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##MYSQLPASS##/$MYSQLPASS/" \
          -e "s/##PREFIXDB##/$PREFIXDB/" \
          -e "s/##GITLABDBPASS##/$GITLABDBPASS/" \
          -e "s/##SMTP##/$SMTP/" \
          -e "s/##EMAIL##/$EMAIL/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-proxy..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
    
  ;;
  "install")
  ;;
  "start")
    echo "Starting syscheck ${PREFIX}-syscheck "
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;
  "restart")
    echo "Restarting syscheck ${PREFIX}-syscheck"
    docker $DOCKERARGS restart ${PREFIX}-syscheck
  ;;

  "init")
    
  ;;
  "stop")
    echo "Stopping syscheck ${PREFIX}-syscheck "
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
  "remove")
    echo "Removing syscheck ${PREFIX}-syscheck "
  docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
  "clean")
    echo "Cleaning image ${PREFIX}-syscheck"
  ;;
  "purge")
    echo "Purging syscheck ${PREFIX}-syscheck"
    rm -R $RF
  ;;
esac
