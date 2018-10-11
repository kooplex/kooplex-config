#!/bin/bash

RF=$BUILDDIR/outer-nginx

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-outer-nginx..."
       DIR=$SRV/_outer_nginx
       mkdir -p $DIR
       mkdir -p $DIR/etc $DIR/var
       mkdir -p $DIR/etc/nginx/
       mkdir -p $DIR/etc/nginx/keys/
       mkdir -p $DIR/etc/nginx/sites-enabled

       #files
       CERT=""
       KEY=""

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##DIR##/${DIR}/g" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
      sed -e "s/##CERT##/${CERT}/" \
          -e "s/##KEY##/${KEY}/" \
          -e "s/##PREFIX##/${PREFIX}/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERPORT##/$OUTERHOSTPORT/"  etc/outerhost.conf_template > $RF/etc/nginx/sites-enabled/outerhost.conf
  	 
      echo "2. Building ${PREFIX}-outer-nginx.."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-outer-nginx"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-outer-nginx
  ;;


  "stop")
      echo "Stopping containers of ${PREFIX}-outer-nginx"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-outer-nginx"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF
      
  ;;

esac

