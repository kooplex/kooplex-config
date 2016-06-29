#!/bin/bash

case $VERB in
  "build")
    echo "Building $PROJECT-dashboard images"
    echo  "COMPOSE_PROJECT_NAME=$PROJECT" > .env
    echo  "PROJECT_NETWORK=$PROJECT-net" >> .env
    docker-compose $DOCKERARGS build
  ;;
  "install")
  ;;
  "start")
    echo "Starting proxy $PROJECT-proxy [$PROXYIP]"
    docker-compose $DOCKERARGS up -d
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping  and removing $PROJECT-dashboards "
    docker-compose $DOCKERARGS down
  ;;
  "remove")
  ;;
  "clean")
  docker rmi ${PROJECT}_dashboards ${PROJECT}_kernel_gateway
  ;;
esac
