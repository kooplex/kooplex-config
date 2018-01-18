#!/bin/bash

RF=$BUILDDIR/hub

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

#FIXME: get rid of PROJECT (db-name)
#TODO: Volume mountpoints may be part of settings.py

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-hub..."
      
      mkdir -p $SRV/mysql $SRV/_git $SRV/_share $SRV/home $SRV/_report/html $SRV/_report/dashboard $SRV/_hub.grabage
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/home -o o=bind ${PREFIX}-home
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_share -o o=bind ${PREFIX}-share
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_git -o o=bind ${PREFIX}-git
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/mysql -o o=bind ${PREFIX}-hubdb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_report/html -o o=bind ${PREFIX}-report-html
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_report/dashboard -o o=bind ${PREFIX}-report-dashboard
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_hub.grabage -o o=bind ${PREFIX}-garbage

      LDAPPW=$(getsecret ldap)
      GITLABPASS=$(getsecret gitlab)
      SSHKEYPASS=$(getsecret sshkey)
  
      cp Dockerfile.hub $RF
      cp Dockerfile.hubdb $RF
      cp scripts/patch-codeNdbschema.sh $RF
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##HUBDBUSER##/${HUBDBUSER}/g" \
          -e "s/##HUBDBPW##/${HUBDBPW}/g" \
          -e "s/##HUBDBROOTPW##/${HUBDBROOTPW}/" scripts/runserver.sh > $RF/runserver.sh
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##HUBDBUSER##/${HUBDBUSER}/g" \
          -e "s/##HUBDBPW##/${HUBDBPW}/g" \
          -e "s/##HUBDBROOTPW##/${HUBDBROOTPW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
      sed -e "s/##HUBDB##/${HUBDB}/" \
          -e "s/##HUBDBUSER##/${HUBDBUSER}/" \
          -e "s/##HUBDBPW##/${HUBDBPW}/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERPORT##/$OUTERHOSTPORT/" \
          -e "s/##INNERHOST##/$INNERHOST/" \
          -e "s/##INNERHOSTNAME##/$INNERHOSTNAME/" \
          -e "s/##DBHOST##/${PREFIX}-hub-mysql/" \
          -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##LDAPBASEDN##/$LDAPORG/" \
          -e "s/##LDAPUSER##/admin/" \
          -e "s/##LDAPBINDPW##/$LDAPPW/" \
          -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
          -e "s/##GITLABADMINPW##/${GITLABADMINPW}/" \
          -e "s/##GITLABADMINKEYPW##/$SSHKEYPASS/" \
          -e "s/##GITLABDB##/${GITLABDB}/" \
          -e "s/##GITLABDBUSER##/postgres/" \
          -e "s/##GITLABDBPW##/$GITLABDBPW/" \
          -e "s/##DOCKERHOST##/$(echo $DOCKERIP | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERAPIURL##/$(echo $DOCKERAPIURL | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERPORT##/$DOCKERPORT/" \
          -e "s/##DOCKERPROTOCOL##/$DOCKERPROTOCOL/" \
          -e "s/##IPPOOLLO##/$IPPOOLB/" \
          -e "s/##IPPOOLHI##/$IPPOOLE/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" etc/settings.py-template > $RF/settings.py
  	 
      echo "2. Building ${PREFIX}-hub..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-hub"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hub-mysql
#       docker exec ${PREFIX}-hub-mysql /initdb.sh
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hub
  ;;

  "init")
  ;;

  "refresh")
     #FIXME: docker $DOCKERARGS exec $PREFIX-hub bash -c "cd /kooplexhub; git pull;"
  ;;

  "stop")
      echo "Stopping containers of ${PREFIX}-hub"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-hub"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-home
      docker $DOCKERARGS volume rm ${PREFIX}-share
      docker $DOCKERARGS volume rm ${PREFIX}-git
      docker $DOCKERARGS volume rm ${PREFIX}-hubdb
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-hubdb"
    rm -R -f $SRV/mysql
    
  ;;

  "clean")
  ;;

esac

