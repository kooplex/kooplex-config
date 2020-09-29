#!/bin/bash

MODULE_NAME=hydra
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

# After consent install
# /consent/install and click the button
# sed 'files'; #### --> 'database'; ####
#

CONSENT_LOG=$LOG_DIR/hydraconsent
HYDRA_LOG=$LOG_DIR/${MODULE_NAME}
HYDRA_CONF=$CONF_DIR/hydra
HYDRACONSENT_CONF=$CONF_DIR/hydraconsent
HYDRA_DB=$SRV/_hydradb
HYDRA_CONSENTDB=$SRV/_hydraconsentdb
HYDRA_CONSENTCODE=$SRV/_hydracode

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-hydra..."
      
      mkdir -p $HYDRA_DB $HYDRA_CONSENTDB $HYDRA_CONSENTCODE $HYDRACONSENT_CONF $HYDRA_CONF $CONSENT_LOG $HYDRA_LOG
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_DB -o o=bind ${PREFIX}-hydradb
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_CONSENTDB -o o=bind ${PREFIX}-hydraconsentdb
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_CONSENTCODE -o o=bind ${PREFIX}-hydracode
      docker $DOCKERARGS volume create -o type=none -o device=$CONSENT_LOG -o o=bind ${PREFIX}-hydraconsent-log
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_LOG -o o=bind ${PREFIX}-hydra-log
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_CONF -o o=bind ${PREFIX}-hydra-conf
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRACONSENT_CONF -o o=bind ${PREFIX}-hydraconsent-conf

#      [ -d $SRV/_hydracode/consent ] && mv  $SRV/_hydracode/consent $SRV/_hydracode/consent_$(date +"%Y%m%d_%H%M")
#      Magically put the code into $SRV/_hydracode/consent

      cp etc/nginx.conf $HYDRACONSENT_CONF/

      #cp -ar src $SRV/_hydracode 
      if [ -d $HYDRA_CONSENTCODE/.git ] ; then
          echo $HYDRA_CONSENTCODE
          #cd $DIR && git pull && cd -
      else
          git clone https://github.com/kooplex/hydra-consent.git $HYDRA_CONSENTCODE
      fi


      cp -a $BUILDDIR/CA/rootCA.{key,crt} $HYDRACONSENT_CONF/

      ENCFILE=$HYDRA_CONF/hydraconsent.enckey
      if [ ! -f $ENCFILE ] ; then
	 hexdump -n 16 -e '"%08X"' /dev/random > $ENCFILE
      fi

# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)

      sed -e "s/##PREFIX##/$PREFIX/"  etc/sites.conf-template > $HYDRACONSENT_CONF/sites.conf
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/"  etc/hydra.yml-template > $HYDRA_CONF/hydra.yml

      cp etc/mysql.cnf etc/*entrypoint.sh  $RF/
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRACONSENTDB##/$HYDRACONSENTDB/" \
          -e "s/##HYDRACONSENTDB_USER##/$HYDRACONSENTDB_USER/" \
          -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  etc/database.php-template >  $HYDRA_CONSENTCODE/application/config/database.php
#          -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  etc/database.php-template > $RF/database.php # $SRV/_hydracode/consent/application/config/database.php
#      sed -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  Dockerfile.hydraconsent-template > $RF/Dockerfile.hydraconsent
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
          -e "s,##OUTERHOST##,$OUTERHOST," \
	  -e "s,##CONSENT_ENCRYPTIONKEY##,$(cat $ENCFILE),"  consentconfig/config.php-template > $HYDRA_CONSENTCODE/application/config/config.php

    if [ ! ${PULL_IMAGE_FROM_REPOSITORY} ]; then
             echo "2. Building ${PREFIX}-${MODULE_NAME}.."
             cp scripts/* $RF
             sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.hydra-template > $RF/Dockerfile.hydra
#             sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.keto-template > $RF/Dockerfile.keto
             docker $DOCKER_HOST build -f $RF/Dockerfile.hydra -t ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}hydra $RF

             sed -e "s/##PREFIX##/${PREFIX}/"\
                 -e "s,##OUTERHOST##,$OUTERHOST," \
                 -e "s/##MAIL_SERVER_HOSTNAME##/$MAIL_SERVER_HOSTNAME/" \
	     Dockerfile.hydraconsent-template > $RF/Dockerfile.hydraconsent
             docker $DOCKER_HOST build -f $RF/Dockerfile.hydraconsent -t ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}hydraconsent $RF

             cp Dockerfile.hydraconsentdb $RF/
             docker $DOCKER_HOST build -f $RF/Dockerfile.hydraconsentdb -t ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}hydraconsent-mysql $RF
             #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
        if [ ${IMAGE_REPOSITORY_URL} ]; then
              docker $DOCKERARGS push ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}hydra:${IMAGE_REPOSITORY_VERSION}
              docker $DOCKERARGS push ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}hydraconsent:${IMAGE_REPOSITORY_VERSION}
              docker $DOCKERARGS push ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}hydraconsent-mysql:${IMAGE_REPOSITORY_VERSION}
        fi 
    fi

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s,##OUTERHOST##,$OUTERHOST," \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/" \
          -e "s/##HYDRA_API_USER##/$HYDRA_API_USER/" \
          -e "s/##HYDRA_API_PW##/$HYDRA_API_PW/" \
	  -e "s/##HYDRASYSTEM_SECRET##/$HYDRASYSTEM_SECRET/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
          -e "s/##HYDRACONSENTDB##/${HYDRACONSENTDB}/g" \
          -e "s/##HYDRACONSENTDB_USER##/${HYDRACONSENTDB_USER}/g" \
          -e "s/##HYDRACONSENTDB_PW##/${HYDRACONSENTDB_PW}/g" \
          -e "s/##HYDRADB##/${HYDRADB}/g" \
          -e "s/##HYDRADB_USER##/${HYDRADB_USER}/g" \
          -e "s/##HYDRADB_PW##/${HYDRADB_PW}/g" \
          -e "s,##IMAGE_REPOSITORY_URL##,${IMAGE_REPOSITORY_URL},g" \
          -e "s,##IMAGE_REPOSITORY_PREFIX##,${IMAGE_REPOSITORY_PREFIX},g" \
          -e "s,##IMAGE_REPOSITORY_VERSION##,${IMAGE_REPOSITORY_VERSION},g"  \
          -e "s/##HYDRADBROOT_PW##/${HYDRADBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

  ;;

  "install-hydra")

    HYDRA_IP=`IP=$(docker $DOCKERARGS inspect ${PREFIX}-hydra | grep "\"IPAddress\": \"172"); echo ${IP%*,} | sed -e 's/"//g' | sed 's/,//g' | awk '{print $2}'`
    cat hydra-conf/public-policy.json  | curl -u ${HYDRA_API_USER}:${HYDRA_API_PW}            ${HYDRA_IP}:5000/api/new-policy/${PREFIX}-public -H "Content-Type: application/json" -X POST --data-binary @-
    register_hydra "consent"

    HYDRA_CONSENTSECRET=`cat $SRV/.secrets/$PREFIX-consent-hydra.secret`
    cat << EOF > ${HYDRA_CONSENTCODE}/application/config/hydra.php 
<?php defined('BASEPATH') || exit('No direct script access allowed');
  
\$config["hydra.consent_client"] = '${PREFIX}-consent';
\$config["hydra.url"] = '${REWRITEPROTO}://${OUTERHOST}/hydra';
\$config["hydra.consent_secret"] = '${HYDRA_CONSENTSECRET}';
EOF

  ;;
  "uninstall-hydra")
    HYDRA_IP=`IP=$(docker $DOCKERARGS inspect ${PREFIX}-hydra | grep "\"IPAddress\": \"172"); echo ${IP%*,} | sed -e 's/"//g' | sed 's/,//g' | awk '{print $2}'`

    curl -X DELETE -u ${HYDRA_API_USER}:${HYDRA_API_PW} ${HYDRA_IP}:5000/api/remove/${PREFIX}-public
    unregister_hydra "consent"
  ;;
  "install-nginx")
    register_nginx $MODULE_NAME
  ;;
  "uninstall-nginx")
    unregister_nginx $MODULE_NAME
  ;;
  "start")
       echo "Starting containers of ${PREFIX}-hydra"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydra-postgresql
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydraconsent-mysql
#       docker exec ${PREFIX}-hydra-mysql /initdb.sh
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydraconsent
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydra
#       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-keto

    echo "Now you need to install hydra consent at $OUTERHOST/consent/install"
  ;;

  "init")

  
	docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "CREATE DATABASE $HYDRADB;" ||\
        if [ $? -eq 0 ];then
          docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "CREATE USER $HYDRADB_USER WITH PASSWORD '$HYDRADB_USER';"
          docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "GRANT ALL ON DATABASE $HYDRADB TO $HYDRADB_USER;"
          docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "GRANT CONNECT ON DATABASE $HYDRADB to $HYDRADB_USER;"

  	  docker restart ${PREFIX}-hydra
	  sleep 2
        
        fi

        docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW -e  "create user '$HYDRACONSENTDB_USER'@'%' identified by '$HYDRACONSENTDB_PW';"
	docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW -e  "create database $HYDRACONSENTDB;"
	docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW -e  "GRANT ALL  privileges on $HYDRACONSENTDB.* to $HYDRACONSENTDB_USER;"

## This might give an error first. It might be that first we need to load the site first in browser
	docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW $HYDRACONSENTDB -e  "update bf_settings set value = 'noreply@elte.hu' where name = 'sender_email';"

#\c monitor
#GRANT readaccess TO usage_viewer;
#ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON DATABASE $HYDRADB TO $HYDRADB_USER;
#GRANT USAGE ON SCHEMA public to usage_viewer;
#GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO usage_viewer;
#GRANT SELECT ON ALL TABLES IN SCHEMA public TO usage_viewer;



  ;;

  "refresh")
  ;;

  "stop")
      echo "Stopping containers of ${PREFIX}-hydra"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-hydra"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
      echo "Removing $RF" 
    rm -r $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-hydradb
      docker $DOCKERARGS volume rm ${PREFIX}-hydra-conf
      docker $DOCKERARGS volume rm ${PREFIX}-hydra-log
      docker $DOCKERARGS volume rm ${PREFIX}-hydraconsentdb
      docker $DOCKERARGS volume rm ${PREFIX}-hydraconsent-conf
      docker $DOCKERARGS volume rm ${PREFIX}-hydraconsent-log
      docker $DOCKERARGS volume rm ${PREFIX}-hydracode
      docker $DOCKERARGS volume rm ${PREFIX}-hydraconfig
#      rm  -r $HYDRA_CONF
  ;;
  "clean")
    #echo "Cleaning data ${PREFIX}-hydradb"
    #rm -R -f $SRV/mysql
    rm -r $HYDRA_CONSENTDB $HYDRA_DB $HYDRA_CONSENTCODE $HYDRACONSENT_CONF $HYDRA_CONF $CONSENT_LOG $HYDRA_LOG
    
  ;;


esac

