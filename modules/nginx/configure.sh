#!/bin/bash

MODULE_NAME=nginx
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml
NGINX_HTML=$DATA_DIR/${MODULE_NAME}
NGINX_LOG=$LOG_DIR/${MODULE_NAME}
NGINX_CONF=$CONF_DIR/${MODULE_NAME}

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."
      mkdir -p $NGINX_HTML $NGINX_LOG $NGINX_CONF/sites-enabled

      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_HTML  -o o=bind ${PREFIX}-nginx-html
      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_LOG  -o o=bind ${PREFIX}-nginx-log
      docker $DOCKERARGS volume create -o type=none -o device=$NGINX_CONF  -o o=bind ${PREFIX}-nginx-conf

      cp etc/custom* $NGINX_HTML/
      cp scripts/* $RF/
     
       sed -e "s/##CERT##/${PREFIX}.crt/g" \
           -e "s/##KEY##/${PREFIX}.key/g" \
           -e "s/##PREFIX##/${PREFIX}/g" \
           -e "s/##OUTERHOST##/$OUTERHOST/" \
           -e "s/##OUTERPORT##/$OUTERHOSTPORT/"  etc/outerhost.conf-template > $NGINX_CONF/default.conf

    if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
         IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
    else
         #IMAGE_NAME=${PREFIX}-${MODULE_NAME}
         IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
             echo "2. Building ${PREFIX}-${MODULE_NAME}.."
             sed -e "s/##PREFIX##/${PREFIX}/g"  Dockerfile-template > $RF/Dockerfile
             docker $DOCKER_HOST build -f $RF/Dockerfile -t ${IMAGE_NAME} $RF
        if [ ${IMAGE_REPOSITORY_URL} ]; then
              docker $DOCKERARGS push ${IMAGE_NAME}
        fi 
             #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    fi

      sed -e "s/##PREFIX##/${PREFIX}/g" \
           -e "s/##NGINX_API_USER##/${NGINX_API_USER}/g" \
           -e "s/##NGINX_API_PW##/${NGINX_API_PW}/g" \
           -e "s/##MODULE_NAME##/${MODULE_NAME}/g" \
           -e "s,##IMAGE_REPOSITORY_URL##,${IMAGE_REPOSITORY_URL},g" \
           -e "s,##IMAGE_REPOSITORY_PREFIX##,${IMAGE_REPOSITORY_PREFIX},g" \
           -e "s,##IMAGE_REPOSITORY_VERSION##,${IMAGE_REPOSITORY_VERSION},g"  docker-compose.yml-template > $DOCKER_COMPOSE_FILE
  
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
  "clean")
    rm -r -f $NGINX_HTML $NGINX_LOG $NGINX_CONF
  ;;

esac

