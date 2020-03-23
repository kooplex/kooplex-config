#!/bin/bash
MODULE_NAME=gitea
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml
GITEA_CONF=$CONF_DIR/${MODULE_NAME}

# INIT for openid
# ${MODULE_NAME} admin auth add-oauth --name kooplex-test --provider openidConnect --auto-discover-url https://kooplex-test.elte.hu/hydra/.well-known/openid-configuration --key kooplex-test-${MODULE_NAME} --secret vmi

# GITEA html templates from https://github.com/go-gitea/gitea.git

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
        -e "s/##ROOTURL##/${REWRITEPROTO}:\/\/$OUTERHOST\/gitea/" \
        -e "s/##GITEANET##/$GITEANET/" \
        -e "s/##GITEADB_ROOTPW##/$GITEAADMINPW/" \
        -e "s/##GITEADB##/$GITEADB/" \
        -e "s/##GITEADB_USER##/$GITEAUSER/" \
        -e "s/##GITEADB_PW##/$GITEADBPW/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
        -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
        -e "s/##GITEADB_ROOTPW##/$GITEAADMINPW/" \
        -e "s/##GITEADB##/$GITEADB/" \
        -e "s/##GITEADB_USER##/$GITEAUSER/" \
        -e "s/##GITEADB_PW##/$GITEADBPW/" etc/app.ini-template > $RF/app.ini
    
   echo "2. Building ${PREFIX}-${MODULE_NAME}..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 

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
# We need to add the oauth provider to gitea mysql
# use kooplex-test_gitea
# update login_source set cfg = '{"Provider":"openidConnect","ClientID":"kooplex-test-gitea","ClientSecret":"LbIiHbIKpDsd","OpenIDConnectAutoDiscoveryURL":"https://kooplex-test.elte.hu/hydra/.well-known/openid-configuration","CustomURLMapping":null}' where id = 2;

# The "name" in this line should be the same as the string in the calback url before the "/callback"

  "start")
    echo "Starting container ${PREFIX}-${MODULE_NAME}"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;
  "init")
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
      rm  $NGINX_DIR/conf/conf/${MODULE_NAME}
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-${MODULE_NAME}"
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
    rm -R -f $SRV/_${MODULE_NAME}data
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-db
    rm -R -f $SRV/_${MODULE_NAME}db
    
  ;;

  "purge")
  ;;
esac
