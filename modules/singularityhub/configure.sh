#!/bin/bash

RF=$BUILDDIR/singularity

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-singularity..."

    mkdir -p $SRV/_singularity-uwsgi
    mkdir -p $SRV/_singularity-db

    SREGISTRY_CODEDIR=$SRV/_singularity-code
#    mkdir -p $SREGISTRY_CODEDIR
    if [ ! -d $SREGISTRY_CODEDIR ] ; then
            git clone https://github.com/singularityhub/sregistry $SREGISTRY_CODEDIR
    fi


    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_singularity-db -o o=bind ${PREFIX}-singularity-db
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_singularity-uwsgi -o o=bind ${PREFIX}-singularity-uwsgi
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_singularity-code -o o=bind ${PREFIX}-singularity-code

    cp Dockerfile.nginx uwsgi_params.par $RF/

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
	-e "s/##SINGULARITYDB_PW##/$SINGULARITYDB_PW/" \
	-e "s/##SINGULARITY_SECRET##/$SINGULARITY_SECRET/" \
	-e "s/##SEAFILE_ADMINPW##/$DUMMYPASS/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
	-e "s/##SINGULARITY_SECRET##/$SINGULARITY_SECRET/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" secrets.py-template > $SREGISTRY_CODEDIR/shub/settings/secrets.py

    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
	-e "s/##SINGULARITYDB_PW##/$SINGULARITYDB_PW/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" config.py-template > $SREGISTRY_CODEDIR/config.py
    
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" nginx.conf-template > $RF/nginx.conf
    
   echo "2. Building ${PREFIX}-singularity..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
 ;;

  "install")
  ;;

  "start")
    echo "Starting container ${PREFIX}-singularity"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "init")
  ;;

  "admin")
     echo "Creating Seafile admin user..."
	docker $DOCKERARGS exec -it ${PREFIX}-singularity /opt/singularity/singularity-server-latest/reset-admin.sh
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-singularity"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm    
  ;;

  "cleandata")
    echo "Cleaning data ${PREFIX}-singularity"
    docker $DOCKERARGS volume rm ${PREFIX}-singularity-data
    rm -R -f $SRV/_singularity-data  
  ;;

  "purge")
###    echo "Removing $RF" 
###    rm -R -f $RF
###    docker $DOCKERARGS volume rm ${PREFIX}-singularity-data
  ;;

esac
