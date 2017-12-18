#!/bin/bash

RF=$BUILDDIR/impersonator

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-impersonator..."
      sed -e "s/##PREFIX##/$PREFIX/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
      sed -i -e "s/##PROJECT##/$PROJECT/" $DOCKER_COMPOSE_FILE
      cp Dockerfile $RF
      cp scripts/start.sh $RF
      cp scripts/share.sh $RF
      cp scripts/init-ssh-agent.sh $RF
      cp scripts/patch.sh $RF
      cp scripts/patch-davfs.sh $RF
      cp etc/nsswitch.conf $RF
#      sed -e "s/##LDAPURI##/ldap:\/\/$LDAPSERV/" \
#          -e "s/##LDAPBASE##/ou=users,$LDAPORG/" \
#          -e "s/##LDAPBINDDN##/cn=admin,$LDAPORG/" \
#          -e "s/##LDAPBINDPW##/$LDAPPASS/" \
#          -e "s/##LDAPBINDROOT##/cn=admin,$LDAPORG/" \
#          -e "s/##LDAPBINDROOTPW##/$LDAPPASS/" etc/nslcd.conf_template > $RF/nslcd.conf
      ldap_nslcdconfig > $RF/nslcd.conf
      chmod 0600 $RF/nslcd.conf

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

