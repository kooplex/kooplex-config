#!/bin/bash

# try to allocate dashboards server ports from this port value
DASHBOARDS_PORT=3000

RF=$BUILDDIR/dashboard

mkdir -p $RF

DIR_DBSOURCE=$RF/dashboards_server
URL_DBSOURCE=https://github.com/jupyter-incubator/dashboards_server.git
DOCKER_HOST=$DOCKERARGS

#TODO:
# everything generated shold be residing in a separate generated folder ./build


case $VERB in
  "build")
    for DOCKER_FILE in ../notebook/image-*/Dockerfile
    do
      TMP=$(dirname $DOCKER_FILE)
      POSTFIX=${TMP##*image-}
      DOCKER_COMPOSE_FILE=$RF/docker-compose.yml-$POSTFIX

      echo "0. Check for dashboards server sources..."
      if [ -d $DIR_DBSOURCE ] ; then
        echo "\tfound in $DIR_DBSOURCE"
      else
        echo "\tcloning..."
        git clone $URL_DBSOURCE $DIR_DBSOURCE
      fi


      echo "1. Building dockerfile file for $POSTFIX..."
      IMAGE=kooplex-notebook-$POSTFIX
      KGW_DOCKERFILE=$RF/Dockerfile.kernel-$POSTFIX
#TODO: check the existance of the docker image by docker images
      sed -e "s/##IMAGE##/$IMAGE/" Dockerfile.kernel.template > $KGW_DOCKERFILE

      echo "2. Building compose file $DOCKER_COMPOSE_FILE..."
      KGW=kernel-gateway-$POSTFIX
      VOL=$(echo $DASHBOARDSDIR/$POSTFIX | sed s"/\//\\\\\//"g)
      KGW_DOCKERFILE_ESCAPED=$(echo $KGW_DOCKERFILE | sed s"/\//\\\\\//"g)
      DBS_DOCKERFILE_ESCAPED=$(echo $RF/Dockerfile.dashboards | sed s"/\//\\\\\//"g)

      sed -e "s/##KERNELGATEWAY##/$KGW/" \
          -e "s/##KERNELGATEWAY_DOCKERFILE##/$KGW_DOCKERFILE_ESCAPED/" \
          -e "s/##VOLUME##/$VOL/" \
          -e "s/##NETWORK##/${PROJECT}-net/" \
        docker-compose.yml.KGW_template > $DOCKER_COMPOSE_FILE

#TODO: when more dashboards do a loop here
      DASHBOARDS_NAME=kooplex-dashboards-$POSTFIX
      sed -e "s/##KERNELGATEWAY##/$KGW/" \
          -e "s/##DASHBOARDS_DOCKERFILE##/$DBS_DOCKERFILE_ESCAPED/" \
          -e "s/##DASHBOARDS##/$DASHBOARDS_NAME/" \
          -e "s/##VOLUME##/$VOL/" \
          -e "s/##DASHBOARDS_PORT##/$DASHBOARDS_PORT/" \
        docker-compose.yml.DBRD_template >> $DOCKER_COMPOSE_FILE
      DASHBOARDS_PORT=$((DASHBOARDS_PORT + 1))   
#NOTE: inner loop over dashboards for a given gateway should end here

      echo "3. Building images for $POSTFIX..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
   done
  ;;

  "install")
  ;;

  "start")  
    for DOCKER_COMPOSE_FILE in $RF/docker-compose.yml-*
    do
      echo "Starting service for $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
    sleep 2
   done
  ;;

  "init")  
  ;;

  "stop")
    for DOCKER_COMPOSE_FILE in $RF/docker-compose.yml-*
    do
      echo "Stopping and removing services in $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
    done
  ;;
    
  "remove")
    for DOCKER_COMPOSE_FILE in $RF/docker-compose.yml-*
    do
      POSTFIX=${DOCKER_COMPOSE_FILE##*docker-compose.yml-}
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
#FIXME: should not we remove images and generated Dockerfiles?
    done
  ;;

  "purge")
    echo "Removing $RF" 
    rm -R -f $RF
#NOTE: dashboards are stored elsewhere in $DASHBOARDSDIR
  ;;

  "clean")
  ;;
esac

