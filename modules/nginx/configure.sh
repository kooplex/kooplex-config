#!/bin/bash

MODULE_NAME=nginx
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml
NGINX_HTML=$DATA_DIR/nginx
NGINX_LOG=$LOG_DIR/nginx
NGINX_CONF=$CONF_DIR/nginx

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."
      mkdir -p $NGINX_HTML 
      mkdir -p $NGINX_LOG
      mkdir -p $NGINX_CONF/sites-enabled

      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_HTML  -o o=bind ${PREFIX}-nginx-html
      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_LOG  -o o=bind ${PREFIX}-nginx-log
      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_CONF  -o o=bind ${PREFIX}-nginx-conf
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

       sed -e "s/##PREFIX##/${PREFIX}/g" \
           -e "s/##NGINX_API_USER##/${NGINX_API_USER}/g" \
           -e "s/##NGINX_API_PW##/${NGINX_API_PW}/g" \
           -e "s/##MODULE_NAME##/${MODULE_NAME}/g"  docker-compose.yml_template > $DOCKER_COMPOSE_FILE

       sed -e "s/##PREFIX##/${PREFIX}/g"  Dockerfile-template > $RF/Dockerfile
  
       sed -e "s/##CERT##/${PREFIX}.crt/g" \
           -e "s/##KEY##/${PREFIX}.key/g" \
           -e "s/##PREFIX##/${PREFIX}/g" \
           -e "s/##OUTERHOST##/$OUTERHOST/" \
           -e "s/##OUTERPORT##/$OUTERHOSTPORT/"  etc/outerhost.conf-template > $NGINX_CONF/default.conf
  	 
      echo "2. Building ${PREFIX}-${MODULE_NAME}.."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-${MODULE_NAME}"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-${MODULE_NAME}
  ;;


  "stop")
      echo "Stopping containers of ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF

      docker $DOCKERARGS volume rm ${PREFIX}-nginx-conf
      docker $DOCKERARGS volume rm ${PREFIX}-nginx-log
      docker $DOCKERARGS volume rm ${PREFIX}-nginx-html
      
  ;;

esac

