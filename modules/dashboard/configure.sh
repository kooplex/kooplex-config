#!/bin/bash

case $VERB in
  "build")
  
    mkdir -p $SRV/dashboards
    
    echo "Building $PROJECT-dashboards images"
    echo  "COMPOSE_PROJECT_NAME=$PROJECT" > .env
    echo  "PROJECT_NETWORK=$PROJECT-net" >> .env
    echo  "HOST_DASHBOARDS_VOLUME=/srv/kooplex/compare/dashboards" >> .env
    echo  "PUBLIC_LINK_PATTERN=http://$DOMAIN:3000" >> .env

    docker-compose $DOCKERARGS build
  ;;
  "install")
  ;;
  "start")
    echo "Starting $PROJECT-dashboard"
    docker-compose $DOCKERARGS up -d
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping and removing $PROJECT-dashboard"
    docker-compose $DOCKERARGS down
  ;;
  "remove")
  ;;
  "clean")
  docker rmi ${PROJECT}_dashboards ${PROJECT}_kernel_gateway
  ;;
esac
