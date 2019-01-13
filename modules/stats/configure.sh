#!/bin/bash

RF=$BUILDDIR/stats
mkdir -p $RF
DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "Building image $PREFIX-stats"

    cp scripts/* $RF
    #cp etc/crontab $RF
    cp Dockerfile.stats $RF
    
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##POSTGRESDBPW##/$GITLABDBPW/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

    docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    
  ;;
  "install")

  ;;
  "start")
     echo "Start stats $PROJECT-stats [$STATSIP]"
     docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-stats
  ;;
  "init")
  
  ;;
  "stop")
      echo "Stop stats $PROJECT-stats [$STATSIP]"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down  
      
  ;;    
  "remove")
      echo "Remove stats container $PROJECT-stats [$STATSIP]"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
  "purge")
      echo "Purge   stats $PROJECT-stats [$STATSIP]"
#      docker $DOCKERARGS start $PROJECT-stats

  ;;
  "clean")
#    echo "Cleaning base image $PREFIX-stats"
#    docker $DOCKERARGS volume rm ${PREFIX}-stats 
   
    ;;
esac