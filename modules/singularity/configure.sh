#!/bin/bash

MODULE_NAME=singularity
RF=$BUILDDIR/$MODULE_NAME

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."

    mkdir -p $SRV/_${MODULE_NAME}-uwsgi
    mkdir -p $SRV/_${MODULE_NAME}-db

    SREGISTRY_CODEDIR=$SRV/_${MODULE_NAME}-code
#    mkdir -p $SREGISTRY_CODEDIR
    if [ ! -d $SREGISTRY_CODEDIR ] ; then
            git clone https://github.com/singularityhub/sregistry $SREGISTRY_CODEDIR
    fi


    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-db -o o=bind ${PREFIX}-${MODULE_NAME}-db
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-uwsgi -o o=bind ${PREFIX}-${MODULE_NAME}-uwsgi
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-code -o o=bind ${PREFIX}-${MODULE_NAME}-code

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
    
    
   echo "2. Building ${PREFIX}-${MODULE_NAME}..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
 ;;

  "install")

#For hydra
      sed -e "s/##PREFIX##/${PREFIX}/" hydraconfig/client-policy-${MODULE_NAME}.json-template > $HYDRA_CONFIG/client-policy-${MODULE_NAME}.json
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" hydraconfig/client-${MODULE_NAME}.json-template > $HYDRA_CONFIG/client-${MODULE_NAME}.json

      PWFILE=$RF/consent-${MODULE_NAME}.pw
      if [ ! -f $PWFILE ] ; then
  	  docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/consent-${MODULE_NAME}.json > /consent-${MODULE_NAME}.pw" && \
          docker cp  ${PREFIX}-hydra:/consent-${MODULE_NAME}.pw $PWFILE
      fi
      CONSENTAPPPASSWORD=$(cut -f4 -d\  $PWFILE | cut -d: -f2)

      docker $DOCKERARGS exec ${PREFIX}-hydra sh -c 'hydra policies import /etc/hydraconfig/client-policy-${MODULE_NAME}.json'

  ;;

  "start")
    echo "Starting container ${PREFIX}-${MODULE_NAME}"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-${MODULE_NAME} > $NGINX_DIR/conf/conf/${MODULE_NAME}
  ;;

  "init")
  ;;

  "admin")
     echo "Creating Seafile admin user..."
	docker $DOCKERARGS exec -it ${PREFIX}-${MODULE_NAME} /opt/singularity/singularity-server-latest/reset-admin.sh
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
      rm $NGINX_DIR/conf/conf/${MODULE_NAME}
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm    

      docker exec  ${PREFIX}-hydra  sh -c "hydra clients  delete ${PREFIX}-${MODULE_NAME}"
      PWFILE=$RF/consent-${MODULE_NAME}.pw
      rm $PWFILE
  ;;

  "cleandata")
    echo "Cleaning data ${PREFIX}-${MODULE_NAME}"
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
    rm -R -f $SRV/_${MODULE_NAME}-data  
  ;;

  "purge")
###    echo "Removing $RF" 
###    rm -R -f $RF
###    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
  ;;

esac
