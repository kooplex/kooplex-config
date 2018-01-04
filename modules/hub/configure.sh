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
      LDAPPASS=$(getsecret ldap)
      GITLABPASS=$(getsecret gitlab)
      SSHKEYPASS=$(getsecret sshkey)
  
      cp Dockerfile.hub $RF
      cp Dockerfile.hubdb $RF
      cp scripts/patch-codeNdbschema.sh $RF
      sed -e "s/##PREFIX##/$PREFIX/" scripts/runserver.sh-template > $RF/runserver.sh
      sed -e "s/##PREFIX##/$PREFIX/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
      sed -e "s/##HUBDB##/${PREFIX}_kooplex/" \
          -e "s/##HUBDBUSER##/kooplex/" \
          -e "s/##HUBDBPW##/$MYSQLPASS/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERPORT##/$OUTERHOSTPORT/" \
          -e "s/##INNERHOST##/$INNERHOST/" \
          -e "s/##INNERHOSTNAME##/$INNERHOSTNAME/" \
          -e "s/##DBHOST##/$MYSQLIP/" \
          -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##LDAPBASEDN##/$LDAPORG/" \
          -e "s/##LDAPUSER##/admin/" \
          -e "s/##LDAPBINDPW##/$LDAPPASS/" \
          -e "s/##GITLABADMIN##/gitlabadmin/" \
          -e "s/##GITLABADMINPW##/$GITLABPASS/" \
          -e "s/##GITLABADMINKEYPW##/$SSHKEYPASS/" \
          -e "s/##GITLABDB##/${PROJECT}_gitlabdp/" \
          -e "s/##GITLABDBUSER##/postgres/" \
          -e "s/##GITLABDBPW##/$GITLABDBPASS/" \
          -e "s/##DOCKERHOST##/$DOCKERIP/" \
          -e "s/##DOCKERPORT##/$DOCKERPORT/" \
          -e "s/##DOCKERPROTOCOL##/$DOCKERPROTOCOL/" \
          -e "s/##IPPOOLLO##/$IPPOOLB/" \
          -e "s/##IPPOOLHI##/$IPPOOLE/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" etc/settings.py-template > $RF/settings.py
      sed -e "s/##HUBDB##/${PREFIX}_kooplex/" \
          -e "s/##HUBDBUSER##/kooplex/" \
          -e "s/##HUBDBPW##/$MYSQLPASS/" \
          -e "s/##HUBDBROOTPW##/$MYSQLPASS/" scripts/initdb.sh-template > $RF/initdb.sh
      chmod +x $RF/dbinit.sh
  	 
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
     #FIXME: docker $DOCKERARGS exec $PROJECT-hub bash -c "cd /kooplexhub; git pull;"
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

