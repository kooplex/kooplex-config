#!/bin/bash

RF=$BUILDDIR/impersonator

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-impersonator..."
      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-template > $RF/Dockerfile

      cp scripts/start.sh $RF
      cp scripts/init-ssh-agent.sh $RF
      cp etc/nsswitch.conf $RF
      sed -e "s/##PREFIX##/$PREFIX/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
      sed -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##MINUID##/$MINUID/" scripts/patch-davfs.sh-template > $RF/patch-davfs.sh
      sed -e "s/##LDAPPORT##/$LDAPPORT/" \
          -e "s/##LDAPBINDROOT##/cn=admin,$LDAPORG/" \
          -e "s/##LDAPBASE##/ou=users,$LDAPORG/" \
          -e "s/##LDAPBINDROOTPW##/$DUMMYPASS/"  scripts/patch-gitconfig.sh_template > $RF/patch-gitconfig.sh
      sed -e "s/##LDAPPORT##/$LDAPPORT/" \
          -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##LDAPPW##/$LDAPPW/" \
          -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##INNERHOST##/$INNERHOST/" \
          -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
          -e "s/##GITLABADMINPW##/${GITLABADMINPW}/" \
          -e "s/##LDAPBINDPW##/$DUMMYPASS/" scripts/create_admin.sh-template > $RF/create_admin.sh
      sed -e "s/##LDAPURI##/ldap:\/\/$LDAPSERV/" \
          -e "s/##LDAPBASE##/ou=users,$LDAPORG/" \
          -e "s/##LDAPBINDDN##/cn=admin,$LDAPORG/" \
          -e "s/##LDAPBINDPW##/$LDAPPW/" \
          -e "s/##LDAPBINDROOT##/cn=admin,$LDAPORG/" \
          -e "s/##LDAPBINDROOTPW##/$LDAPPW/" etc/nslcd.conf_template > $RF/nslcd.conf
      sed -e "s/##OWNCLOUDURL##/http:\/\/${PREFIX}-nginx\/ownCloud\/ocs\/v1.php\/apps\/files_sharing\/api\/v1\/shares/" \
          -e "s/##WEBDAVPATTERN##/http:..${PREFIX}-nginx.ownCloud.remote.php.webdav./" scripts/share.sh_template > $RF/share.sh
      chmod 0600 $RF/nslcd.conf
      chmod 0755 $RF/share.sh
      chmod 0755 $RF/patch-gitconfig.sh

      echo "2. Building ${PREFIX}-impersonator..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;

  "install")
  ;;

  "start")  
      echo "Starting container ${PREFIX}-impersonator"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "init")  
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-impersonator"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
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

