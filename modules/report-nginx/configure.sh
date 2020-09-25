#!/bin/bash
MODULE_NAME=report-nginx
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

REPORTNGINX_HTML=$DATA_DIR/${MODULE_NAME}
REPORTNGINX_LOG=$LOG_DIR/${MODULE_NAME}
REPORTNGINX_CONF=$CONF_DIR/${MODULE_NAME}

case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-report-nginx..."

      mkdir -p $REPORTNGINX_HTML $REPORTNGINX_LOG $REPORTNGINX_CONF/sites-enabled

      docker $DOCKERARGS volume create -o type=none -o device=$REPORTNGINX_HTML  -o o=bind ${PREFIX}-${MODULE_NAME}-html
      docker $DOCKERARGS volume create -o type=none -o device=$REPORTNGINX_LOG  -o o=bind ${PREFIX}-${MODULE_NAME}-log
      docker $DOCKERARGS volume create -o type=none -o device=$REPORTNGINX_CONF  -o o=bind ${PREFIX}-${MODULE_NAME}-conf

      cp Dockerfile $RF
      cp scripts/* $RF/
      cp etc/custom* $REPORTNGINX_HTML/

      sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERHOSTNAME##/$OUTERHOSTNAME/" etc/sites.conf > $REPORTNGINX_CONF/sites.conf

    if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
        IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
    else 
        #IMAGE_NAME=${PREFIX}-${MODULE_NAME}
        IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
        echo "2. Building ${PREFIX}-${MODULE_NAME}.."
        docker $DOCKER_HOST build -f $RF/Dockerfile -t ${IMAGE_NAME} $RF
        #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    fi

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s,##REPORTNGINX_HTML##,$REPORTNGINX_HTML," \
          -e "s/##NGINX_API_USER##/${NGINX_API_USER}/g" \
          -e "s/##NGINX_API_PW##/${NGINX_API_PW}/g" \
          -e "s/##MODULE_NAME##/${MODULE_NAME}/g" \
          -e "s,##IMAGE_NAME##,${IMAGE_NAME},g" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

  ;;

  "install-hydra")
  #  register_hydra $MODULE_NAME
  ;;
  "uninstall-hydra")
   # unregister_hydra $MODULE_NAME
  ;;
  "install-nginx")
    register_nginx $MODULE_NAME
  ;;
  "uninstall-nginx")
    unregister_nginx $MODULE_NAME
  ;;

  "start")
    echo "Starting report-nginx ${PREFIX}-report-nginx"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "restart")
    echo "Restarting report-nginx ${PREFIX}-report-nginx"
    docker $DOCKERARGS restart $PREFIX-report-nginx
  ;;

  "init")
  ;;
    
  "stop")
    echo "Stopping report-nginx ${PREFIX}-report-nginx"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
    echo "Removing report-nginx ${PREFIX}-net"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
    
  "purge")
    echo "Purging report-nginx ${PREFIX}-report-nginx"
    rm -R $RF

    docker $DOCKERARGS volume rm ${PREFIX}-report-nginx-conf
    docker $DOCKERARGS volume rm ${PREFIX}-report-nginx-log
    docker $DOCKERARGS volume rm ${PREFIX}-report-nginx-html
  ;;
  "clean")
   rm -r $REPORTNGINX_HTML $REPORTNGINX_LOG $REPORTNGINX_CONF

  ;;  
esac
