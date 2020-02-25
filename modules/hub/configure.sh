#!/bin/bash

MODULE_NAME=hub
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

HUB_LOG=$LOG_DIR/hub

#FIXME: get rid of PROJECT (db-name)
#TODO: Volume mountpoints may be part of settings.py
HYDRA_API_USER=hydrauser
HYDRA_API_PW=hydrapw

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-hub..."
      
      mkdir -p $SRV/_hubcode_ $SRV/mysql $SRV/_git $SRV/_share $SRV/home $SRV/_report \
         $SRV/_hub.garbage $SRV/_course $SRV/_usercourse $SRV/_assignment \
         $SRV/_workdir $SRV/_git $HUB_LOG
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/home -o o=bind ${PREFIX}-home
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_course -o o=bind ${PREFIX}-course
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_usercourse -o o=bind ${PREFIX}-usercourse
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_assignment -o o=bind ${PREFIX}-assignment
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_share -o o=bind ${PREFIX}-share
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/mysql -o o=bind ${PREFIX}-hubdb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hub.garbage -o o=bind ${PREFIX}-garbage
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hubcode_ -o o=bind ${PREFIX}-hubcode
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_workdir -o o=bind ${PREFIX}-workdir
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_git -o o=bind ${PREFIX}-git
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_report -o o=bind ${PREFIX}-report
      docker $DOCKERARGS volume create -o type=none -o device=$HUB_LOG -o o=bind ${PREFIX}-hub-log

      DIR=$SRV/_hubcode_
      if [ -d $DIR/.git ] ; then
          echo $DIR
          #cd $DIR && git pull && cd -
      else
          git clone https://github.com/kooplex/kooplex-hub.git $DIR
      fi

      cp $BUILDDIR/CA/rootCA.crt $RF/

# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)
      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.hub-template > $RF/Dockerfile.hub
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" scripts/runserver.sh > $RF/runserver.sh
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERPORT##/$OUTERHOSTPORT/" \
          -e "s/##INNERHOST##/$INNERHOST/" \
          -e "s/##INNERHOSTNAME##/$INNERHOSTNAME/" \
          -e "s/##DBHOST##/${PREFIX}-hub-mysql/" \
          -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##LDAPBASEDN##/$LDAPORG/" \
          -e "s/##LDAPUSER##/admin/" \
          -e "s/##LDAPBIND_PW##/$HUBLDAP_PW/" \
          -e "s/##HUBLDAP_PW##/$HUBLDAP_PW/" \
          -e "s/##DJANGO_SECRET_KEY##/$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g')/" \
          -e "s/##MINUID##/$MINUID/" \
          -e "s/##DOCKERHOST##/$(echo $DOCKERIP | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERAPIURL##/$(echo $DOCKERAPIURL | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERPORT##/$DOCKERPORT/" \
          -e "s/##DOCKERPROTOCOL##/$DOCKERPROTOCOL/" \
          -e "s/##DOCKER_VOLUME_DIR##/$(echo $DOCKER_VOLUME_DIR | sed s"/\//\\\\\//"g)/" \
          -e "s/##IPPOOLLO##/$IPPOOLB/" \
          -e "s/##IPPOOLHI##/$IPPOOLE/" \
          -e "s/##HYDRA_OIDC_SECRET_HUB##/${HYDRA_OIDC_SECRET_HUB}/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" \
          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
          -e "s/##HUB_USER##/${HUB_USER}/g" \
          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
  	 

      echo "2. Building ${PREFIX}-hub..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install-nginx")
      echo "Installing containers of ${PREFIX}-${MODULE_NAME}"

      sed -e "s/##PREFIX##/$PREFIX/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" etc/nginx-${MODULE_NAME}-conf-template | curl -u ${NGINX_API_USER}:${NGINX_API_PW}\
	        ${NGINX_IP}:5000/api/new/${MODULE_NAME} -H "Content-Type: text/plain" -X POST --data-binary @-
 ;;
  "install-hydra")
      echo "Installing containers of ${PREFIX}-${MODULE_NAME}"

      sed -e "s/##PREFIX##/$PREFIX/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" etc/hydra-${MODULE_NAME}-client-template | curl -u ${HYDRA_API_USER}:${HYDRA_API_PW}\
	        ${HYDRA_IP}:5000/api/new-client/${PREFIX}-${MODULE_NAME} -H "Content-Type: application/json" -X POST --data-binary @-

      sed -e "s/##PREFIX##/$PREFIX/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" etc/hydra-${MODULE_NAME}-policy-template | curl -u ${HYDRA_API_USER}:${HYDRA_API_PW}\
	        ${HYDRA_IP}:5000/api/new-policy/${PREFIX}-${MODULE_NAME} -H "Content-Type: application/json" -X POST --data-binary @-

#      PWFILE=$RF/consent-${MODULE_NAME}.pw
#      if [ ! -f $PWFILE ] ; then
#  	  docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/consent-${MODULE_NAME}.json > /consent-${MODULE_NAME}.pw" && \
#          docker cp  ${PREFIX}-hydra:/consent-${MODULE_NAME}.pw $PWFILE
#      fi
#      CONSENTAPPPASSWORD=$(cut -f4 -d\  $PWFILE | cut -d: -f2)
#
#      docker $DOCKERARGS exec ${PREFIX}-hydra sh -c 'hydra policies import /etc/hydraconfig/client-policy-${MODULE_NAME}.json'
  ;;
  "uninstall-hydra")
      echo "UnInstalling containers of ${PREFIX}-${MODULE_NAME}"

      echo "Uninstalling containers of ${PREFIX}-${MODULE_NAME}"
      curl -X DELETE -u ${HYDRA_API_USER}:${HYDRA_API_PW} ${HYDRA_IP}:5000/api/remove/${PREFIX}-${MODULE_NAME}
  ;;
  "start")
       echo "Starting containers of ${PREFIX}-hub"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hub-mysql
#       docker exec ${PREFIX}-hub-mysql /initdb.sh
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hub
  ;;

  "init")
       docker exec ${PREFIX}-hub-mysql bash -c "echo 'show databases' | mysql -u root --password=$HUBDBROOT_PW -h $PREFIX-hub-mysql | grep  -q $HUBDB" ||\
       if [ ! $? -eq 0 ];then
          docker exec ${PREFIX}-hub-mysql bash -c " echo \"CREATE DATABASE $HUBDB; CREATE USER '$HUBDB_USER'@'%' IDENTIFIED BY '$HUBDB_PW'; GRANT ALL ON $HUBDB.* TO '$HUBDB_USER'@'%';\" |  \
            mysql -u root --password=$HUBDBROOT_PW  -h $PREFIX-hub-mysql"
       fi
       echo "Created ${PREFIX}-hub database and user created" 
       docker exec ${PREFIX}-hub-mysql bash -c "echo 'use $HUBDB' | mysql -u root --password=$HUBDBROOT_PW -h $PREFIX-hub-mysql"
       docker exec ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py makemigrations
       docker exec ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py migrate
       docker exec -it ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py createsuperuser
       docker exec -it ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py updatemodel 
  ;;

  "refresh")
     #FIXME: docker $DOCKERARGS exec $PREFIX-hub bash -c "cd /kooplexhub; git pull;"
  ;;

  "stop")
      echo "Stopping containers of ${PREFIX}-hub"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "uninstall")
      echo "Uninstalling containers of ${PREFIX}-${MODULE_NAME}"
      curl -u ${NGINX_API_USER}:${NGINX_API_PW} ${NGINX_IP}:5000/api/remove/${MODULE_NAME}

  ;;
  "remove")
      echo "Removing containers of ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm

      docker exec  ${PREFIX}-hydra  sh -c "hydra clients  delete ${PREFIX}-${MODULE_NAME}"
      PWFILE=$RF/consent-${MODULE_NAME}.pw
      rm $PWFILE
  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-home
      docker $DOCKERARGS volume rm ${PREFIX}-course
      docker $DOCKERARGS volume rm ${PREFIX}-usercourse
      docker $DOCKERARGS volume rm ${PREFIX}-share
      docker $DOCKERARGS volume rm ${PREFIX}-hubdb
      docker $DOCKERARGS volume rm ${PREFIX}-garbage
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-hubdb"
    rm -R -f $SRV/mysql
    
  ;;

  "clean")
  ;;

esac

