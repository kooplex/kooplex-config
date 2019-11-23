#!/bin/bash

RF=$BUILDDIR/overleaf

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

# README
# works only if serves on :8080 or any other port, but not through the outer-nginx, since it doesn_t have a BASE_URL property


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-overleaf..."

    CODEDIR=$RF/githubcode
    if [ ! -d $CODEDIR ] ; then
        git clone https://github.com/overleaf/overleaf.git $CODEDIR
    fi
    mkdir -p $SRV/_overleaf-data $SRV/_overleaf-redis_data $SRV/_overleaf-mongo_data

    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_overleaf-data -o o=bind ${PREFIX}-overleaf-data
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_overleaf-redis_data -o o=bind ${PREFIX}-overleaf-redis_data
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_overleaf-mongo_data -o o=bind ${PREFIX}-overleaf-mongo_data

    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" Dockerfile_template  > $RF/Dockerfile


#    sed -e "s/##SEAFILEDB_PW##/$SEAFILEDBPW/" \
#	-e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
#        -e "s/##OUTERHOST##/$OUTERHOST/" conf/ccnet.conf-template > $RF/ccnet.conf
    
   echo "2. Building ${PREFIX}-overleaf..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
 ;;

  "install")
  ;;

  "start")
    echo "Starting container ${PREFIX}-overleaf"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-overleaf > $NGINX_DIR/conf/conf/overleaf
  ;;

  "init")

# $ docker exec sharelatex /bin/bash -c "cd /var/www/sharelatex; grunt user:create-admin --email joe@example.com"
# After password reset the password can be found in one of the logs /var/log/sharelatex/*
# https://github.com/overleaf/web/issues/264
  ;;

  "admin")
     echo "Creating Seafile admin user..."
	docker $DOCKERARGS exec -it ${PREFIX}-overleaf /opt/overleaf/overleaf-server-latest/reset-admin.sh
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-overleaf"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
      rm $NGINX_DIR/conf/conf/overleaf
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm    
  ;;

  "cleandata")
    echo "Cleaning data ${PREFIX}-overleaf"
    docker $DOCKERARGS volume rm ${PREFIX}-overleaf-data
    rm -R -f $SRV/_overleaf-data  
  ;;

  "purge")
###    echo "Removing $RF" 
###    rm -R -f $RF
###    docker $DOCKERARGS volume rm ${PREFIX}-overleaf-data
  ;;

esac
