#!/bin/bash

RF=$BUILDDIR/outer-nginx

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml
NGINX_HTML=$DATA_DIR/nginx
NGINX_LOG=$LOG_DIR/nginx
NGINX_CONF=$CONF_DIR/nginx

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-outer-nginx..."
      mkdir -p $NGINX_HTML 
      mkdir -p $NGINX_LOG
      mkdir -p $NGINX_CONF

      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_HTML  -o o=bind ${PREFIX}-outernginx-html
      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_LOG  -o o=bind ${PREFIX}-outernginx-log
      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_CONF  -o o=bind ${PREFIX}-outernginx-conf
#       mkdir -p $DIR
#       mkdir -p $DIR/etc $DIR/var
#       mkdir -p $DIR/etc/nginx/
#       mkdir -p $DIR/etc/nginx/keys/
#       mkdir -p $DIR/etc/nginx/sites-enabled
#       cp -a keys $DIR/etc/nginx/
#       cp $KEYFILE $CERTFILE $DIR/etc/nginx/keys/
#       cp -ar $KEYS/* $RF/

      cp etc/custom* $NGINX_HTML/
      cp scripts/* $RF/

       sed -e "s/##PREFIX##/${PREFIX}/g"  docker-compose.yml_template > $DOCKER_COMPOSE_FILE
       sed -e "s/##PREFIX##/${PREFIX}/g"  Dockerfile-template > $RF/Dockerfile
  
       sed -e "s/##CERT##/${PREFIX}.crt/g" \
           -e "s/##KEY##/${PREFIX}.key/g" \
           -e "s/##PREFIX##/${PREFIX}/g" \
           -e "s/##OUTERHOST##/$OUTERHOST/" \
           -e "s/##OUTERPORT##/$OUTERHOSTPORT/"  etc/outerhost.conf-template > $NGINX_CONF/default.conf
  	 
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

