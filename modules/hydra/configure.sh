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
HYDRA_CONF=$CONF_DIR/${MODULE_NAME}

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-hydra..."
      
      mkdir -p $SRV/_hydradb $SRV/_hydraconsentdb $SRV/_hydracode $HYDRA_CONF $CONSENT_LOG $HYDRA_LOG
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hydradb -o o=bind ${PREFIX}-hydradb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hydraconsentdb -o o=bind ${PREFIX}-hydraconsentdb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hydracode -o o=bind ${PREFIX}-hydracode
      docker $DOCKERARGS volume create -o type=none -o device=$CONSENT_LOG -o o=bind ${PREFIX}-hydraconsent-log
      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_LOG -o o=bind ${PREFIX}-hydra-log
#      docker $DOCKERARGS volume create -o type=none -o device=$HYDRA_CONF -o o=bind ${PREFIX}-hydra-conf

#      [ -d $SRV/_hydracode/consent ] && mv  $SRV/_hydracode/consent $SRV/_hydracode/consent_$(date +"%Y%m%d_%H%M")
#      Magically put the code into $SRV/_hydracode/consent

      cp Dockerfile.hydraconsentdb $RF/
      cp etc/mysql.cnf $RF/
      cp etc/nginx.conf $RF/
      cp etc/*entrypoint.sh $RF/
      cp scripts/* $RF/

#      cp Dockerfile.hydraconsent-template $RF/Dockerfile.hydraconsent
      #cp -ar src $SRV/_hydracode 
      cp -a hydraconfig/{public-policy.json,consent-app-policy.json,consent-app.json}   $HYDRA_CONFIG/

      cp -a $BUILDDIR/CA/rootCA.{key,crt} $RF/

      ENCFILE=$RF/hydraconsent.enckey
      if [ ! -f $ENCFILE ] ; then
	 hexdump -n 16 -e '"%08X"' /dev/random > $ENCFILE
      fi



# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)
      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.hydra-template > $RF/Dockerfile.hydra
#      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.keto-template > $RF/Dockerfile.keto

      sed -e "s/##PREFIX##/${PREFIX}/"\
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##MAIL_SERVER_HOSTNAME##/$MAIL_SERVER_HOSTNAME/" \
	      Dockerfile.hydraconsent-template > $RF/Dockerfile.hydraconsent
      sed -e "s/##PREFIX##/$PREFIX/"  etc/sites.conf-template > $RF/sites.conf
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRACONSENTDB##/$HYDRACONSENTDB/" \
          -e "s/##HYDRACONSENTDB_USER##/$HYDRACONSENTDB_USER/" \
          -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  etc/database.php-template > $RF/database.php # $SRV/_hydracode/consent/application/config/database.php
#      sed -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  Dockerfile.hydraconsent-template > $RF/Dockerfile.hydraconsent
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
	  -e "s/##CONSENT_ENCRYPTIONKEY##/$(cat $ENCFILE)/"  consentconfig/config.php-template > $SRV/_hydracode/consent/application/config/config.php
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/"  etc/hydra.yml-template > $RF/hydra.yml
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/" \
	  -e "s/##HYDRASYSTEM_SECRET##/$HYDRASYSTEM_SECRET/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
          -e "s/##HYDRACONSENTDB##/${HYDRACONSENTDB}/g" \
          -e "s/##HYDRACONSENTDB_USER##/${HYDRACONSENTDB_USER}/g" \
          -e "s/##HYDRACONSENTDB_PW##/${HYDRACONSENTDB_PW}/g" \
          -e "s/##HYDRADB##/${HYDRADB}/g" \
          -e "s/##HYDRADB_USER##/${HYDRADB_USER}/g" \
          -e "s/##HYDRADB_PW##/${HYDRADB_PW}/g" \
          -e "s/##HYDRADBROOT_PW##/${HYDRADBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE


  	 
      echo "2. Building ${PREFIX}-hydra..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install-hydra")
  #  register_hydra $MODULE_NAME
  ;;
  "uninstall-hydra")
   # unregister_hydra $MODULE_NAME
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
  ;;

  "init")

  
	docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "CREATE DATABASE $HYDRADB;"
        docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "CREATE USER $HYDRADB_USER WITH PASSWORD '$HYDRADB_USER';"
        docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "GRANT ALL ON DATABASE $HYDRADB TO $HYDRADB_USER;"
        docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "GRANT CONNECT ON DATABASE $HYDRADB to $HYDRADB_USER;"

	docker restart ${PREFIX}-hydra
	sleep 2
        
        docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW -e  "create user $HYDRACONSENTDB_USER identified by '$HYDRACONSENTDB_PW';"
	docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW -e  "create database $HYDRACONSENTDB;"
	docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW -e  "GRANT ALL  privileges on $HYDRACONSENTDB.* to $HYDRACONSENTDB_USER;"

	echo "I need to sleep for 10 secs"
	sleep 10

	docker exec  ${PREFIX}-hydra  sh -c "hydra policies create -f /etc/hydraconfig/public-policy.json"
	docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/client-hub.json"
	PWFILE=$RF/consent-app.pw
	if [ ! -f $PWFILE ] ; then
		docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/consent-app.json > /consent-app.pw" && \
			docker cp  ${PREFIX}-hydra:/consent-app.pw $PWFILE
	fi
	CONSENTAPPPASSWORD=$(cut -f4 -d\  $PWFILE | cut -d: -f2)
        sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
            -e "s/##OUTERHOST##/$OUTERHOST/" \
            -e "s/##CONSENTPASSWORD##/$CONSENTAPPPASSWORD/" consentconfig/hydra.php-template > $SRV/_hydracode/consent/application/config/hydra.php

#	hydra 0.x esetén:
	docker exec  ${PREFIX}-hydra  sh -c "hydra policies import /etc/hydraconfig/consent-app-policy.json"
	docker exec  ${PREFIX}-hydra  sh -c "hydra policies import /etc/hydraconfig/client-policy-hub.json"

#	hydra 1.x esetén:
#	docker exec  ${PREFIX}-hydra  sh -c "hydra policies create -f /etc/hydraconfig/consent-app-policy.json"
#	docker exec  ${PREFIX}-hydra  sh -c "hydra policies create -f /etc/hydraconfig/client-policy-hub.json"

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
      rm $NGINX_DIR/conf/conf/hydra
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-hydra"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-hydradb
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-hydradb"
    rm -R -f $SRV/mysql
    
  ;;

  "clean")
  ;;

esac

