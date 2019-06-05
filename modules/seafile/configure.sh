#!/bin/bash

RF=$BUILDDIR/seafile

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-seafile..."

    mkdir -p $SRV/_seafile-data

    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_seafile-data -o o=bind ${PREFIX}-seafile-data

    cp Dockerfile.seafile $RF/

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    
    sed -e "s/##SEAFILEDB_PW##/$SEAFILEDBPW/" \
	-e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" bootstrap.py-template > $RF/bootstrap.py

    sed -e "s/##SEAFILEDB_PW##/$SEAFILEDBPW/" \
	-e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" conf/ccnet.conf-template > $RF/ccnet.conf
    
   echo "2. Building ${PREFIX}-seafile..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
 ;;

  "install")
  ;;

  "start")
    echo "Starting container ${PREFIX}-seafile"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "init")
  ;;

  "admin")
     echo "Creating Seafile admin user..."
	docker $DOCKERARGS exec -it ${PREFIX}-seafile /opt/seafile/seafile-server-latest/reset-admin.sh
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-seafile"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm    
  ;;

  "cleandata")
    echo "Cleaning data ${PREFIX}-seafile"
    docker $DOCKERARGS volume rm ${PREFIX}-seafile-data
    rm -R -f $SRV/_seafile-data  
  ;;

  "purge")
###    echo "Removing $RF" 
###    rm -R -f $RF
###    docker $DOCKERARGS volume rm ${PREFIX}-seafile-data
  ;;

esac
