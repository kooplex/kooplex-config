#!/bin/bash

#@ https://medium.com/@alash3al/ssh-into-any-docker-container-remotely-7cfe744a57e3
#@ https://github.com/alash3al/dockssh                                                                                                                                                                             │
																										   # SETUP redis for storing passwords                                                                                                                                                                                │
#SET PASSWORD                                                                                                                                                                                                      


RF=$BUILDDIR/dockssh

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-dockssh..."

#    mkdir -p $SRV/_dockssh-redis-db
#    docker $DOCKERARGS volume create -o type=none -o device=/$SRV/_dockssh-redis-db -o o=bind dockssh-redis-db 

      cp  entrypoint.sh $RF/
      sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERHOSTNAME##/$OUTERHOSTNAME/" \
          -e "s/##INNERHOST##/$INNERHOST/" Dockerfile.dockssh-template > $RF/Dockerfile.dockssh
      
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-dockssh..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")
    echo "Starting dockssh ${PREFIX}-dockssh"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting dockssh ${PREFIX}-dockssh"
    docker $DOCKERARGS restart $PREFIX-dockssh
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping dockssh ${PREFIX}-dockssh"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing dockssh ${PREFIX}-net"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging dockssh ${PREFIX}-dockssh"
    rm -R $RF
  ;;
    
esac
