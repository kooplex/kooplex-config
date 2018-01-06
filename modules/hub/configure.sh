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

      docker $DOCKERARGS volume create -o type=none -o device=$SRV/home -o o=bind ${PREFIX}-home
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_share -o o=bind ${PREFIX}-share
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_git -o o=bind ${PREFIX}-git
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/mysql -o o=bind ${PREFIX}-hubdb

      LDAPPASS=$(getsecret ldap)
      GITLABPASS=$(getsecret gitlab)
      SSHKEYPASS=$(getsecret sshkey)
  
      cp Dockerfile.hub $RF
      cp Dockerfile.hubdb $RF
      cp scripts/patch-codeNdbschema.sh $RF
      cp scripts/runserver.sh $RF
      sed -e "s/##PREFIX##/$PREFIX/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
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
          -e "s/##LDAPBINDPW##/$LDAPPASS/" \
          -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
          -e "s/##GITLABADMINPW##/${GITLABADMINPW}/" \
          -e "s/##GITLABADMINKEYPW##/$SSHKEYPASS/" \
          -e "s/##GITLABDB##/${GITLABDB}/" \
          -e "s/##GITLABDBUSER##/postgres/" \
          -e "s/##GITLABDBPW##/$GITLABDBPW/" \
          -e "s/##DOCKERHOST##/$(echo $DOCKERIP | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERPORT##/$DOCKERPORT/" \
          -e "s/##DOCKERPROTOCOL##/$DOCKERPROTOCOL/" \
          -e "s/##IPPOOLLO##/$IPPOOLB/" \
          -e "s/##IPPOOLHI##/$IPPOOLE/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" etc/settings.py-template > $RF/settings.py
      sed -e "s/##HUBDB##/${HUBDB}/" \
          -e "s/##HUBDBUSER##/${HUBDBUSER}/" \
          -e "s/##HUBDBPW##/${HUBDBPW}/" \
          -e "s/##HUBDBROOTPW##/${HUBDBROOTPW}/" scripts/initdb.sh-template > $RF/initdb.sh
      chmod +x $RF/initdb.sh
  	 
      echo "2. Building ${PREFIX}-hub..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-hub"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hub-mysql
       docker exec ${PREFIX}-hub-mysql /initdb.sh
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
  ;;

  "clean")
  ;;

esac

