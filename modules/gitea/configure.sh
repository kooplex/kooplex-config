#!/bin/bash

RF=$BUILDDIR/gitea

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-gitlab..."

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
    
###    cp scripts/docker-entrypoint.sh $RF    
###    sed -e "s/##HOST##/$OUTERHOST/" etc/nginx-gitlab-http.conf.erb > $RF/nginx-gitlab-http.conf.erb
    
   echo "2. Building ${PREFIX}-gitlab..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 

 ;;
  "install")
###    echo "Installing gitlab $PREFIX-gitlab [$GITLABIP]"

  ;;
  "start")
    echo "Starting container ${PREFIX}-gitea"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d


  ;;
  "init")
###    docker $DOCKERARGS exec --user postgres $PREFIX-gitlabdb bash -c 'createdb gitlabhq_production'

   
#    chmod 600 $SRV/gitlab/etc/ssh_host_*
  ;;
  "admin")
###     echo "Creating Gitlab admin user..."
###     docker $DOCKERARGS exec ${PREFIX}-impersonator bash -c /create_admin.sh 
###     sleep 2 
###     docker $DOCKERARGS exec ${PREFIX}-gitlab bash -c /make_admin.sh
###     echo "MAKE SURE THAT GITLABADMIN IS ADMIN!!!!"
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-gitea"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
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
###    echo "Removing $RF" 
###    rm -R -f $RF
###    docker $DOCKERARGS volume rm ${PREFIX}-gitlabdb
  ;;
esac
