#!/bin/bash

MODULE_NAME=manual
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-manual..."
      
      mkdir -p $SRV/_manual
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_manual -o o=bind ${PREFIX}-manual


      cp Dockerfile etc/entrypoint.sh $RF
      # git clone https://github.com/kooplex/Manual.git $SRV/_manual
      #      cp -r etc/* $SRV/_manual
      
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-manual..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")

      echo "Installing containers of ${PREFIX}-${MODULE_NAME}"

      sed -e "s/##PREFIX##/$PREFIX/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" etc/nginx-${MODULE_NAME}-conf-template | curl -u ${NGINX_API_USER}:${NGINX_API_PW}\
	        ${NGINX_IP}:5000/api/new/${MODULE_NAME} -H "Content-Type: text/plain" -X POST --data-binary @-
  ;;

  "start")
    echo "Starting manual ${PREFIX}-manual"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting manual ${PREFIX}-manual"
    docker $DOCKERARGS restart $PREFIX-manual
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping manual ${PREFIX}-manual"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing manual ${PREFIX}-net"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging manual ${PREFIX}-manual"
    rm -R $RF
  ;;
    
esac
