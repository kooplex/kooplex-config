#!/bin/bash

MODULE_NAME=hub
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

HUB_LOG=$LOG_DIR/${MODULE_NAME}
HUB_CONF=$CONF_DIR/${MODULE_NAME}

#FIXME: get rid of PROJECT (db-name)
#TODO: Volume mountpoints may be part of settings.py
HYDRA_API_USER=hydrauser
HYDRA_API_PW=hydrapw

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-hub..."
      
      mkdir -p $SRV/{_hubcode_,mysql,_git,_share,_hub.garbage,_git} $HUB_LOG $HUB_CONF
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/mysql -o o=bind ${PREFIX}-hubdb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hubcode_ -o o=bind ${PREFIX}-hubcode
      docker $DOCKERARGS volume create -o type=none -o device=$HUB_LOG -o o=bind ${PREFIX}-hub-log
      docker $DOCKERARGS volume create -o type=none -o device=$HUB_CONF -o o=bind ${PREFIX}-hub-conf

      DIR=$SRV/_hubcode_
      if [ -d $DIR/.git ] ; then
          echo $DIR
          #cd $DIR && git pull && cd -
      else
          git clone https://github.com/kooplex/kooplex-hub.git $DIR
      fi

    cp $BUILDDIR/CA/rootCA.crt $HUB_CONF/

    if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
        IMAGE_NAME=${IMAGE_REPOSITORY_URL}/${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
    else
         IMAGE_NAME=${PREFIX}-${MODULE_NAME}
             echo "2. Building ${PREFIX}-${MODULE_NAME}.."
             sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.hub-template > $RF/Dockerfile
             sed -e "s/##PREFIX##/$PREFIX/" \
                 -e "s/##HUBDB##/${HUBDB}/g" \
                 -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
                 -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
                 -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" scripts/runserver.sh > $RF/runserver.sh
             docker $DOCKER_HOST build -f $RF/Dockerfile -t ${IMAGE_NAME} $RF
             #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    fi

# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s,##IMAGE_NAME##,${IMAGE_NAME},g" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERPORT##/$OUTERHOSTPORT/" \
          -e "s/##DBHOST##/${PREFIX}-hub-mysql/" \
          -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##LDAPBASEDN##/$LDAPORG/" \
          -e "s/##LDAPUSER##/admin/" \
          -e "s/##LDAPBIND_PW##/$HUBLDAP_PW/" \
          -e "s/##HUBLDAP_PW##/$HUBLDAP_PW/" \
          -e "s,##DJANGO_SECRET_KEY##,${DJANGO_SECRET_KEY}," \
          -e "s/##MINUID##/$MINUID/" \
          -e "s,##DOCKERHOST##, ${DOCKERIP}," \
          -e "s,##DOCKERAPIURL##,${DOCKERAPIURL}," \
          -e "s/##DOCKERPORT##/$DOCKERPORT/" \
          -e "s/##DOCKERPROTOCOL##/$DOCKERPROTOCOL/" \
          -e "s,##DOCKER_VOLUME_DIR##,${DOCKER_VOLUME_DIR}," \
          -e "s/##IPPOOLLO##/$IPPOOLB/" \
          -e "s/##IPPOOLHI##/$IPPOOLE/" \
          -e "s,##HYDRA_OIDC_SECRET_HUB##,${HYDRA_OIDC_SECRET_HUB}," \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" \
          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
          -e "s/##HUB_USER##/${HUB_USER}/g" \
          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
  	 
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


  "stop")
      echo "Stopping containers of ${PREFIX}-hub"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm

  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-hubcode
      docker $DOCKERARGS volume rm ${PREFIX}-hub-log
      docker $DOCKERARGS volume rm ${PREFIX}-hubdb
  ;;

  "clean")
    echo "Cleaning data ${PREFIX}-hubdb"
    rm -R -f $SRV/mysql
    rm -r $RF
  ;;

esac

