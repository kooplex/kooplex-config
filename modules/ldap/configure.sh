#!/bin/bash

RF=$BUILDDIR/ldap

mkdir -p $RF

#    chown -R root $SRV/ldap
#    chmod -R 755 $SRV/ldap

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-ldap..."

     mkdir -p $SRV/ldap/
     mkdir -p $SRV/ldap/etc
     mkdir -p $SRV/ldap/var
     docker $DOCKERARGS volume create -o type=none -o device=$SRV/ldap/etc -o o=bind ${PREFIX}-ldap-etc
     docker $DOCKERARGS volume create -o type=none -o device=$SRV/ldap/var -o o=bind ${PREFIX}-ldap-var
     
      cp Dockerfile $RF
      cp scripts/entrypoint.sh $RF

      sed -e "s/##PREFIX##/${PREFIX}/" \
          -e "s/##SLAPD_PASSWORD##/${LDAPPW}/" \
          -e "s/##SLAPD_CONFIG_PASSWORD##/${LDAPPW}/" \
          -e "s/##SLAPD_DOMAIN##/${LDAPDOMAIN}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      sed -e "s/##LDAPORG##/$LDAPORG/" etc/new_group.ldiftemplate_template > $RF/new_group.ldiftemplate
      sed -e "s/##LDAPORG##/$LDAPORG/" etc/new_user.ldiftemplate_template > $RF/new_user.ldiftemplate

      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$LDAPPW/" \
          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/addgroup.sh_template > $RF/addgroup.sh
      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$LDAPPW/" \
          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/adduser.sh_template > $RF/adduser.sh
          

      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$LDAPPW/" \
          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/init.sh-template > $RF/init.sh
          
      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$LDAPPW/" \
          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/init-core.sh-template > $RF/init-core.sh

      echo "2. Building ${PREFIX}-ldap..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;
  "install")
    echo "Installing slapd $PROJECT-ldap [$LDAPIP]"
    
   #      -p 666:$LDAPPORT \

  ;;
  "start")
      echo "Starting container ${PREFIX}-ldap"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;
  "init")
    echo "Initializing slapd $PROJECT-ldap [$LDAPIP]"
    docker exec ${PREFIX}-ldap bash -c /init.sh
    docker exec ${PREFIX}-ldap bash -c /init-core.sh
    docker exec ${PREFIX}-ldap bash -c "/usr/local/bin/addgroup.sh users 9998"
    docker exec ${PREFIX}-ldap bash -c "/usr/local/bin/addgroup.sh report 9990"
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-ldap"
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
    
    docker $DOCKERARGS volume rm ${PREFIX}-ldap-etc
    docker $DOCKERARGS volume rm ${PREFIX}-ldap-var

  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-ldap"
    rm -R -f $SRV/ldap/
    
  ;;
  "clean")
    echo "Cleaning image ${PREFIX}-ldap"
    docker $DOCKERARGS rmi ${PREFIX}-ldap
  ;;
esac
