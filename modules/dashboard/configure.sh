#!/bin/bash

    DASHBOARD_PORT=3000
    DASHBOARD_PORT_HOST=3000
    ip=81
    KGW_IP_LAST=100

    DOCKER_HOST=$DOCKERARGS

    RF=$BUILDDIR"/dashboard"
    mkdir -p $RF
    
case $VERB in
  "build")
  
    mkdir -p $SRV/dashboards
    cp runner.sh patcher.sh  $RF/

    for IMAGE_DIR in `ls $BUILDDIR/notebooks/image* -d`
    do

	    DOCKER_FILE=$IMAGE_DIR"/Dockerfile"
            IMAGE_TYPE=${IMAGE_DIR##*image-}
	    COMPOSE_FILE=docker-compose.yml-$IMAGE_TYPE
	    echo "BUILDING $COMPOSE_FILE"

	    DASHBOARD_IP=$(ip_addip "$SUBNET" $ip)
	    DASHBOARD_PORT_HOST=$((DASHBOARD_PORT_HOST+1))   
	    ip=$((ip+1))
	    KGW_IP_LAST=$((KGW_IP_LAST+1))
	    IMAGE=kooplex-notebook-$IMAGE_TYPE
	    KERNEL_GATEWAY_CONTAINER_NAME=kernel-gateway-$IMAGE_TYPE
	    KERNEL_GATEWAY_CONTAINER_IP=172.20.0.${KGW_IP_LAST}
	    KERNEL_GATEWAY_IMAGE_NAME=kooplex-kernel-gateway-$IMAGE_TYPE
	    KERNEL_GATEWAY_DOCKERFILE=Dockerfile.kernel-$IMAGE_TYPE
	    DASHBOARDS_DOCKERFILE=Dockerfile.dashboards-$IMAGE_TYPE
	    DASHBOARDS_CONTAINER_NAME=dashboards-$IMAGE_TYPE
	    DASHBOARDS_IMAGE_NAME=kooplex-dashboards-$IMAGE_TYPE
	    sed -e "s/IMAGE/$IMAGE/" Dockerfile.kernel-template > $RF/$KERNEL_GATEWAY_DOCKERFILE
	    cp Dockerfile.dashboards $RF/$DASHBOARDS_DOCKERFILE
	    sed -e "s/kernel_gateway/$KERNEL_GATEWAY_IMAGE_NAME/" docker-compose.yml-template > $RF/$COMPOSE_FILE
	    perl -pi -e "s/##IMAGE_TYPE##/$IMAGE_TYPE/" $RF/$COMPOSE_FILE
	    SRF=`echo $RF | sed -e 's/\//\\\\\//g'`
	    echo $SRF
	    perl -pi -e "s/##RF##/$SRF/" $RF/$COMPOSE_FILE
	    perl -pi -e "s/##INNERHOST##/$INNERHOST/" $RF/$COMPOSE_FILE
	    perl -pi -e "s/dashboards/$DASHBOARDS_IMAGE_NAME/" $RF/$COMPOSE_FILE

	echo "$DASHBOARDS_CONTAINER_NAME and $KERNEL_GATEWAY_CONTAINER_NAME"
    
    echo "Building $PROJECT-dashboards images"

	perl -pi -e "s/##PROJECT_NETWORK##/$PROJECT-net/" $RF/$COMPOSE_FILE
	SDASHBOARDSDIR=`echo $DASHBOARDSDIR | sed -e 's/\//\\\\\//g'`
	echo $SDASHBOARDSDIR
	perl -pi -e "s/##HOST_DASHBOARDS_VOLUME##/$SDASHBOARDSDIR\/$IMAGE_TYPE/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##DASHBOARD_IP##/$DASHBOARD_IP/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##DASHBOARD_PORT##/$DASHBOARD_PORT/" $RF/$COMPOSE_FILE
	SDASHBOARD_PORT_HOST=`echo $DASHBOARD_PORT_HOST | sed -e 's/\//\\\\\//g'`
	perl -pi -e "s/##DASHBOARD_PORT_HOST##/$SDASHBOARD_PORT_HOST/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##DASHBOARDS_DOCKERFILE##/$DASHBOARDS_DOCKERFILE/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##DASHBOARDS_IMAGE_NAME##/$DASHBOARDS_IMAGE_NAME/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##DASHBOARDS_CONTAINER_NAME##/$DASHBOARDS_CONTAINER_NAME/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##KERNEL_GATEWAY_IMAGE_NAME##/$KERNEL_GATEWAY_IMAGE_NAME/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##KERNEL_GATEWAY_CONTAINER_NAME##/$KERNEL_GATEWAY_CONTAINER_NAME/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##KERNEL_GATEWAY_CONTAINER_IP##/$KERNEL_GATEWAY_CONTAINER_IP/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##KERNEL_GATEWAY_DOCKERFILE##/$KERNEL_GATEWAY_DOCKERFILE/" $RF/$COMPOSE_FILE
	perl -pi -e "s/##IMAGE_TYPE##/$IMAGE_TYPE/" $RF/$COMPOSE_FILE

    echo "docker-compose $DOCKER_HOST -f $RF/$COMPOSE_FILE build"
    $DOCKER_COMPOSE $DOCKER_HOST -f $RF/$COMPOSE_FILE build 

   done
  ;;
  "install")
  ;;
  "start")
    
    for IMAGE_DIR in `ls $BUILDDIR/notebooks/image* -d`
    do

            DOCKER_FILE=$IMAGE_DIR"/Dockerfile"
            IMAGE_TYPE=${IMAGE_DIR##*image-}
	    COMPOSE_FILE=docker-compose.yml-$IMAGE_TYPE
	    echo "Starting $COMPOSE_FILE"

	    $DOCKER_COMPOSE $DOCKERARGS -f $RF/$COMPOSE_FILE up -d
	    sleep 2
   done
  ;;
  "init")
    
  ;;
  "stop")

    for IMAGE_DIR in `ls $BUILDDIR/notebooks/image* -d`
    do

            DOCKER_FILE=$IMAGE_DIR"/Dockerfile"
            IMAGE_TYPE=${IMAGE_DIR##*image-}
	    COMPOSE_FILE=docker-compose.yml-$IMAGE_TYPE
	    echo "Stopping and removing $PROJECT-dashboard"
	    echo "docker-compose $DOCKERARGS -f $COMPOSE_FILE down"
	    $DOCKER_COMPOSE $DOCKERARGS -f $RF/$COMPOSE_FILE down
    done

  ;;
  "remove")
    for IMAGE_DIR in `ls $BUILDDIR/notebooks/image* -d`
    do

            DOCKER_FILE=$IMAGE_DIR"/Dockerfile"
            IMAGE_TYPE=${IMAGE_DIR##*image-}
	    COMPOSE_FILE=docker-compose.yml-$IMAGE_TYPE
	    echo "REMOVING $COMPOSE_FILE"

	   
	    $DOCKER_COMPOSE $DOCKERARGS -f $RF/$COMPOSE_FILE kill
	    $DOCKER_COMPOSE $DOCKERARGS -f $RF/$COMPOSE_FILE rm
    
    done
  ;;
  "purge")
   echo "Removing $SRV/dashboard" 
   rm -R -f $SRV/dashboards $RF
  ;;
  "clean")
#  docker rmi ${PROJECT}_dashboards ${PROJECT}_kernel_gateway
  ;;
esac
