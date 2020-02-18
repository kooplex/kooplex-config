#!/bin/bash
MODULE_NAME=proxy
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-proxy..."

      cp Dockerfile $RF
#      sed -e "s/##PUBLICIP##/${PREFIX}-proxy/" \
#          -e "s/##ADMINIP##/${PREFIX}-proxy/"  scripts/entrypoint.sh > $RF/entrypoint.sh
      cp  scripts/entrypoint.sh  $RF/entrypoint.sh
      
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE


      echo "2. Building ${PREFIX}-proxy..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  
  ;;
  "install")
      echo "Installing containers of ${PREFIX}-${MODULE_NAME}"

      sed -e "s/##PREFIX##/$PREFIX/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" etc/nginx-${MODULE_NAME}-conf-template | curl -u ${NGINX_API_USER}:${NGINX_API_PW}\
	        ${NGINX_IP}:5000/api/new/${MODULE_NAME} -H "Content-Type: text/plain" -X POST --data-binary @-
  ;;
  "start")
     echo "Starting proxy ${PREFIX}-proxy "
     docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;
  "restart")
    echo "Restarting proxy ${PREFIX}-proxy"
    docker $DOCKERARGS restart ${PREFIX}-proxy
  ;;

  "init")
    
  ;;
  "stop")
    echo "Stopping proxy ${PREFIX}-proxy "
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
  "uninstall")
      echo "Uninstalling containers of ${PREFIX}-${MODULE_NAME}"
      curl -u ${NGINX_API_USER}:${NGINX_API_PW} ${NGINX_IP}:5000/api/remove/${MODULE_NAME}

  ;;
  "remove")
    echo "Removing proxy ${PREFIX}-proxy "
  docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
  "clean")
    echo "Cleaning image ${PREFIX}-proxy"
  ;;
  "purge")
    echo "Purging proxy ${PREFIX}-proxy"
    rm -R $RF
  ;;

esac
