#!/bin/bash

RF=$BUILDDIR/hydra

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

#FIXME: get rid of PROJECT (db-name)
HYDRACONSENTDB_USER=hydraconsent
HYDRACONSENTDB_PW=almafa123
HYDRACONSENTDB=hydraconsentdb
HYDRADB_USER=hydra
HYDRADB_PW=almafa123
HYDRADB=hydradb
HYDRA_ADMINPW=almafa123

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-hydra..."
      
      mkdir -p $SRV/_hydradb $SRV/_hydraconsentdb $SRV/_hydracode
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hydradb -o o=bind ${PREFIX}-hydradb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hydraconsentdb -o o=bind ${PREFIX}-hydraconsentdb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hydracode -o o=bind ${PREFIX}-hydracode


#Lehuzzuk a hydrat a repobol
#git clone vmi

      cp etc/*  Dockerfile.hydra Dockerfile.hydraconsentdb $RF/
      cp Dockerfile.hydraconsent-template $RF/Dockerfile.hydraconsent
      #cp -ar src $SRV/_hydracode 


      # self sigbed certificate without a prompt
      openssl req -nodes -newkey rsa:2048 -keyout $RF/hydra.key -out $RF/hydra.crt -subj "/C=HU/ST=Budapest/L=Budapest/O=ELTE/OU=KRFT/CN=${PREFIX}-hydra"
      



# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)
#      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.hydra-template > $RF/Dockerfile.hydra
      sed -e "s/##PREFIX##/$PREFIX/"  etc/sites.conf > $RF/sites.conf
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRACONSENTDB##/$HYDRACONSENTDB/" \
          -e "s/##HYDRACONSENTDB_USER##/$HYDRACONSENTDB_USER/" \
          -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  etc/database.php-template > $RF/database.php
#      sed -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  Dockerfile.hydraconsent-template > $RF/Dockerfile.hydraconsent
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/"  etc/hydra.yml-template > $RF/hydra.yml
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/" \
	  -e "s/##HYDRASYSTEM_SECRET##/$(pwgen 32)/" \
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

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-hydra"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydra-postgresql
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydraconsent-mysql
#       docker exec ${PREFIX}-hydra-mysql /initdb.sh
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydraconsent
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydra
  ;;

  "init")
#       docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "CREATE DATABASE $HYDRADB;"
#        docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "CREATE USER $HYDRADB_USER WITH PASSWORD '$HYDRADB_USER';"
#       docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "GRANT ALL ON DATABASE $HYDRADB TO $HYDRADB_USER;"

        docker exec -u postgres ${PREFIX}-hydra-postgresql  psql -c "GRANT CONNECT ON DATABASE $HYDRADB to $HYDRADB_USER;"
        
	
	docker exec ${PREFIX}-hydra-hydraconsent-mysql mysql -password=$HYDRACONSENTDB_PW -e  "create user $HYDRACONSENTDB_USER identified by \'$HYDRACONSENTDB_PW\';"
	docker exec ${PREFIX}-hydra-hydraconsent-mysql mysql -password=$HYDRACONSENTDB_PW -e  "create database $HYDRACONSENTDB;"
	docker exec ${PREFIX}-hydra-hydraconsent-mysql mysql -password=$HYDRACONSENTDB_PW -e  "GRANT ALL  privileges on $HYDRACONSENTDB.* to $HYDRACONSENTDB_USER;"

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
      rm -R -f $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-home
      docker $DOCKERARGS volume rm ${PREFIX}-course
      docker $DOCKERARGS volume rm ${PREFIX}-usercourse
      docker $DOCKERARGS volume rm ${PREFIX}-share
      docker $DOCKERARGS volume rm ${PREFIX}-hydradb
      docker $DOCKERARGS volume rm ${PREFIX}-garbage
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-hydradb"
    rm -R -f $SRV/mysql
    
  ;;

  "clean")
  ;;

esac

