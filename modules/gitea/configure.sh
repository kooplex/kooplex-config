#!/bin/bash
MODULE_NAME=gitea
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

# INIT for openid
# ${MODULE_NAME} admin auth add-oauth --name kooplex-test --provider openidConnect --auto-discover-url https://kooplex-test.elte.hu/hydra/.well-known/openid-configuration --key kooplex-test-${MODULE_NAME} --secret vmi


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."

    mkdir -p $SRV/_${MODULE_NAME}-data $SRV/_${MODULE_NAME}-db

    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-data -o o=bind ${PREFIX}-${MODULE_NAME}-data
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-db -o o=bind ${PREFIX}-${MODULE_NAME}-db

    GITEANET=${PREFIX}-${MODULE_NAME}-privatenet
  
    cp Dockerfile.gitea $RF/

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
  "install")
# OUTER-NGINX
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-${MODULE_NAME}-template > $CONF_DIR/outer_nginx/sites-enabled/${MODULE_NAME}
  	 
#For hydra
      sed -e "s/##PREFIX##/${PREFIX}/" hydraconfig/client-policy-${MODULE_NAME}.json-template > $HYDRA_CONFIG/client-policy-${MODULE_NAME}.json
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" hydraconfig/client-${MODULE_NAME}.json-template > $HYDRA_CONFIG/client-${MODULE_NAME}.json

      PWFILE=$RF/consent-${MODULE_NAME}.pw
      if [ ! -f $PWFILE ] ; then
  	  docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/consent-${MODULE_NAME}.json > /consent-${MODULE_NAME}.pw" 
      fi
      CONSENTAPPPASSWORD=$(cut -f4 -d\  $PWFILE | cut -d: -f2)

      docker $DOCKERARGS exec ${PREFIX}-hydra sh -c 'hydra policies import /etc/hydraconfig/client-policy-${MODULE_NAME}.json'

# We need to add the oauth provider to gitea mysql
# use kooplex-test_gitea
# update login_source set cfg = '{"Provider":"openidConnect","ClientID":"kooplex-test-gitea","ClientSecret":"LbIiHbIKpDsd","OpenIDConnectAutoDiscoveryURL":"https://kooplex-test.elte.hu/hydra/.well-known/openid-configuration","CustomURLMapping":null}' where id = 2;

# The "name" in this line should be the same as the string in the calback url before the "/callback"

  ;;
  "start")
    echo "Starting container ${PREFIX}-${MODULE_NAME}"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d


  ;;
  "init")

   
  ;;
  "admin")
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
      
      docker exec  ${PREFIX}-hydra  sh -c "hydra clients  delete ${PREFIX}-${MODULE_NAME}"
      PWFILE=$RF/consent-${MODULE_NAME}.pw
      rm $PWFILE
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
