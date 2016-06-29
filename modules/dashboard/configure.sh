#!/bin/bash

case $VERB in
  "build")
    echo "Building $PROJECT-dashboard images"
    echo  "COMPOSE_PROJECT_NAME=$PROJECT" > .env
    echo  "PROJECT_NETWORK=$PROJECT-net" >> .env
    docker-compose build
  ;;
  "install")
  ;;
  "start")
    echo "Starting proxy $PROJECT-proxy [$PROXYIP]"
    docker-compose up -d
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping  and removing $PROJECT-dashboards "
    docker-compose down
  ;;
  "remove")
  ;;
  "clean")
  docker rmi ${PROJECT}_dashboards ${PROJECT}_kernel_gateway
  ;;
esac
