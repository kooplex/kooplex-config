#!/bin/bash
MODULE_NAME=gitea
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml
GITEA_CONF=$CONF_DIR/${MODULE_NAME}

case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."

    mkdir -p $SRV/_${MODULE_NAME}-data $SRV/_${MODULE_NAME}-db $GITEA_CONF 

    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-data -o o=bind ${PREFIX}-${MODULE_NAME}-data
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-db -o o=bind ${PREFIX}-${MODULE_NAME}-db
    docker $DOCKERARGS volume create -o type=none -o device=$GITEA_CONF  -o o=bind ${PREFIX}-${MODULE_NAME}-conf

    GITEANET=${PREFIX}-${MODULE_NAME}-privatenet
  
    cp Dockerfile.gitea $RF/
    cp -r templates/* $GITEA_CONF/ 

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
        -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
        -e "s/##GITEADB_ROOTPW##/$GITEAADMINPW/" \
        -e "s/##GITEADB##/$GITEADB/" \
        -e "s/##GITEADB_USER##/$GITEAUSER/" \
        -e "s/##GITEADB_PW##/$GITEADBPW/" etc/app.ini-template > $GITEA_CONF/app.ini

    if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
          IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
    else
	  IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
          #IMAGE_NAME=${PREFIX}-${MODULE_NAME}
          echo "2. Building ${PREFIX}-${MODULE_NAME}.."
          sed -e "s/##PREFIX##/${PREFIX}/g"  Dockerfile.gitea > $RF/Dockerfile
          docker $DOCKER_HOST build -f $RF/Dockerfile -t ${IMAGE_NAME} $RF
        if [ ${IMAGE_REPOSITORY_URL} ]; then
              docker $DOCKERARGS push ${IMAGE_NAME}
        fi 
          #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    fi

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s,##IMAGE_NAME##,${IMAGE_NAME}," \
        -e "s/##ROOTURL##/${REWRITEPROTO}:\/\/$OUTERHOST\/gitea/" \
        -e "s/##GITEANET##/$GITEANET/" \
        -e "s/##GITEADB_ROOTPW##/$GITEAADMINPW/" \
        -e "s/##GITEADB##/$GITEADB/" \
        -e "s/##GITEADB_USER##/$GITEAUSER/" \
        -e "s/##GITEADB_PW##/$GITEADBPW/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

    

 ;;
  "install-hydra")
    register_hydra $MODULE_NAME
  ;;
  "uninstall-hydra")
    unregister_hydra $MODULE_NAME
  ;;
  "install-nginx")
    register_nginx $MODULE_NAME
  ;;
  "uninstall-nginx")
    unregister_nginx $MODULE_NAME
  ;;
  "init")
    docker exec $PREFIX-${MODULE_NAME} bash -c "cp /data/gitea/templates/app.ini /data/gitea/conf/app.ini"
    docker restart $PREFIX-${MODULE_NAME}

    HYDRA_GITEACLIENTSECRET=`cat $SRV/.secrets/$PREFIX-gitea-hydra.secret`
    docker exec $PREFIX-${MODULE_NAME} bash -c "su git -c 'gitea admin auth add-oauth --name $PREFIX-${MODULE_NAME} --provider openidConnect --auto-discover-url $REWRITEPROTO://$OUTERHOST/hydra/.well-known/openid-configuration --key $PREFIX-${MODULE_NAME} --secret $HYDRA_GITEACLIENTSECRET' "
    docker restart $PREFIX-${MODULE_NAME}
  ;;
  "start")
    echo "Starting container ${PREFIX}-${MODULE_NAME}"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
      #rm  $NGINX_DIR/conf/conf/${MODULE_NAME}
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
  "clean")
    echo "Cleaning data ${PREFIX}-${MODULE_NAME}"
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
    rm -R -f $SRV/_${MODULE_NAME}-data
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-db
    rm -R -f $SRV/_${MODULE_NAME}-db
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-conf
    rm -R -f $GITEA_CONF
    
  ;;

  "purge")
    rm -r $RF
  ;;
esac
