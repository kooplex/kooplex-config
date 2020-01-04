#!/bin/bash

RF=$BUILDDIR/report-nginx

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in

  "build")
    echo "1. Configuring ${PREFIX}-report-nginx..."

#    if [ $REWRITEPROTO = "http" ]; then
#      EXTRACONFIG="ports:\n      - 80:80"
#    fi

      cp Dockerfile $RF
      cp etc/nginx.conf $RF
      sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERHOSTNAME##/$OUTERHOSTNAME/" \
          -e "s/##INNERHOST##/$INNERHOST/" etc/sites.conf > $RF/sites.conf
      
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##EXTRACONFIG##/$EXTRACONFIG/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      echo "2. Building ${PREFIX}-report-nginx..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
# OUTER-NGINX
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-${MODULE_NAME}-template > $CONF_DIR/outer_nginx/sites-enabled/${MODULE_NAME}
#        docker $DOCKERARGS restart $PREFIX-outer-nginx
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
  ;;
    
esac
