#!/bin/bash

RF=$BUILDDIR/gitea

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

# INIT for openid
# gitea admin auth add-oauth --name kooplex-test --provider openidConnect --auto-discover-url https://kooplex-test.elte.hu/hydra/.well-known/openid-configuration --key kooplex-test-gitea --secret vmi


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-gitea..."

    mkdir -p $SRV/_gitea-data $SRV/_gitea-db

    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_gitea-data -o o=bind ${PREFIX}-gitea-data
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_gitea-db -o o=bind ${PREFIX}-gitea-db

    GITEANET=${PREFIX}-gitea-privatenet
  
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##ROOTURL##/https:\/\/kooplex-test.elte.hu\/gitea/" \
        -e "s/##GITEANET##/$GITEANET/" \
        -e "s/##GITEADB_ROOTPW##/$GITEAADMINPW/" \
        -e "s/##GITEADB##/$GITEADB/" \
        -e "s/##GITEADB_USER##/$GITEAUSER/" \
        -e "s/##GITEADB_PW##/$GITEADBPW/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    

   echo "2. Building ${PREFIX}-gitea..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 

 ;;
  "install")

  ;;
  "start")
    echo "Starting container ${PREFIX}-gitea"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-gitea > $NGINX_DIR/conf/conf/gitea


  ;;
  "init")

   
  ;;
  "admin")
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-gitea"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
      rm  $NGINX_DIR/conf/conf/gitea
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
      
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-gitea"
    docker $DOCKERARGS volume rm ${PREFIX}-gitea-data
    rm -R -f $SRV/_giteadata
    docker $DOCKERARGS volume rm ${PREFIX}-gitea-db
    rm -R -f $SRV/_giteadb
    
  ;;

  "purge")
  ;;
esac
