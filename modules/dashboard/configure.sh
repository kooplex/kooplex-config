#!/bin/bash

    port=3000
    ip=81

DOCKER_HOST=$DOCKERARGS

case $VERB in
  "build")
  
    mkdir -p $SRV/dashboards

    for DOCKER_FILE in `ls ../notebook/image*/Docker*`
    do
	 

#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-numpy-git
#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-dashboard-numpy
#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-base
    DOCKER_IMAGE=${DOCKER_FILE##*Dockerfile-}
    COMPOSE_FILE=docker-compose.yml-$DOCKER_IMAGE
    echo "BUILDING $COMPOSE_FILE"

    DASHBOARD_IP=$(ip_addip "$SUBNET" $ip)
    DASHBOARD_PORT=$port
     port=$((port+1))   
     ip=$((ip+1))
    ENVFILE=$DOCKER_IMAGE".env"
    IMAGE=kooplex-notebook-$DOCKER_IMAGE
    KERNEL_GATEWAY_CONTAINER_NAME=kernel-gateway-$DOCKER_IMAGE
    KERNEL_GATEWAY_IMAGE_NAME=kooplex-kernel-gateway-$DOCKER_IMAGE
    KERNEL_GATEWAY_DOCKERFILE=Dockerfile.kernel-$DOCKER_IMAGE
    DASHBOARDS_DOCKERFILE=Dockerfile.dashboards-$DOCKER_IMAGE
    DASHBOARDS_CONTAINER_NAME=dashboards-$DOCKER_IMAGE
    DASHBOARDS_IMAGE_NAME=kooplex-dashboards-$DOCKER_IMAGE
    sed -e "s/IMAGE/$IMAGE/" Dockerfile.kernel-template > $KERNEL_GATEWAY_DOCKERFILE
    cp Dockerfile.dashboards $DASHBOARDS_DOCKERFILE
    sed -e "s/kernel_gateway/$KERNEL_GATEWAY_IMAGE_NAME/" docker-compose.yml-template > $COMPOSE_FILE
    perl -pi -e "s/dashboards/$DASHBOARDS_IMAGE_NAME/" $COMPOSE_FILE

	echo "$DASHBOARDS_CONTAINER_NAME and $KERNEL_GATEWAY_CONTAINER_NAME"
    
    echo "Building $PROJECT-dashboards images"

    cat << EOF > $ENVFILE  
COMPOSE_PROJECT_NAME=$PROJECT
IMAGE=$IMAGE
PROJECT_NETWORK=$PROJECT-net
HOST_DASHBOARDS_VOLUME=$DASHBOARDSDIR
DASHBOARD_IP=$DASHBOARD_IP
DASHBOARD_PORT=$DASHBOARD_PORT
DASHBOARDS_DOCKERFILE=$DASHBOARDS_DOCKERFILE 
DASHBOARDS_IMAGE_NAME=$DASHBOARDS_IMAGE_NAME
DASHBOARDS_CONTAINER_NAME=$DASHBOARDS_CONTAINER_NAME 
KERNEL_GATEWAY_IMAGE_NAME=$KERNEL_GATEWAY_IMAGE_NAME 
KERNEL_GATEWAY_CONTAINER_NAME=$KERNEL_GATEWAY_CONTAINER_NAME
KERNEL_GATEWAY_DOCKERFILE=$KERNEL_GATEWAY_DOCKERFILE
PUBLIC_LINK_PATTERN=http://$DASHBOARD_IP:$DASHBOARD_PORT
TRUST_PROXY=true
BASE_URL='[/alma]'
EOF

    cp $ENVFILE .env
 docker-compose $DOCKER_HOST -f $COMPOSE_FILE build 

   done
  ;;
  "install")
  ;;
  "start")
    
    for DOCKER_FILE in `ls ../notebook/image*/Docker*`
    do

#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-numpy-git
#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-dashboard-numpy
#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-base
    DOCKER_IMAGE=${DOCKER_FILE##*Dockerfile-}
    COMPOSE_FILE=docker-compose.yml-$DOCKER_IMAGE
    echo "Starting $COMPOSE_FILE"
    ENVFILE=$DOCKER_IMAGE".env"
    cp $ENVFILE .env

    docker-compose $DOCKERARGS -f $COMPOSE_FILE up -d
    sleep 2
   done
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping and removing $PROJECT-dashboard"

    for DOCKER_FILE in `ls ../notebook/image*/Docker*`
    do
    
    DOCKER_IMAGE=${DOCKER_FILE##*Dockerfile-}         
    COMPOSE_FILE=docker-compose.yml-$DOCKER_IMAGE
    docker-compose $DOCKERARGS -f $COMPOSE_FILE down
    
    done
  ;;
  "remove")
    for DOCKER_FILE in `ls ../notebook/image*/Docker*`
    do

#           DOCKER_FILE=../notebook/image-numpy-git/Dockerfile-numpy-git
    DOCKER_IMAGE=${DOCKER_FILE##*Dockerfile-}
    COMPOSE_FILE=docker-compose.yml-$DOCKER_IMAGE
    echo "REMOVING $COMPOSE_FILE"
    ENVFILE=$DOCKER_IMAGE".env"
    cp $ENVFILE .env

    docker-compose $DOCKERARGS -f $COMPOSE_FILE kill
    docker-compose $DOCKERARGS -f $COMPOSE_FILE rm
    
    done
  ;;
  "purge")
   echo "Removing $SRV/dashboard" 
   rm -R -f $SRV/dashboards
  ;;
  "clean")
#  docker rmi ${PROJECT}_dashboards ${PROJECT}_kernel_gateway
  ;;
esac
