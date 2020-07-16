#!/bin/bash

MODULE_NAME=ldap
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

#    chown -R root $SRV/ldap
#    chmod -R 755 $SRV/ldap

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."

     mkdir -p $SRV/{ldap,ldap/etc,ldap/var}
     docker $DOCKERARGS volume create -o type=none -o device=$SRV/ldap/etc -o o=bind ${PREFIX}-ldap-etc
     docker $DOCKERARGS volume create -o type=none -o device=$SRV/ldap/var -o o=bind ${PREFIX}-ldap-var
     
      cp Dockerfile $RF
      cp scripts/entrypoint.sh $RF


      sed -e "s/##PREFIX##/${PREFIX}/" \
          -e "s/##SLAPD_PASSWORD##/${HUBLDAP_PW}/" \
          -e "s/##SLAPD_CONFIG_PASSWORD##/${HUBLDAP_PW}/" \
          -e "s/##SLAPD_DOMAIN##/${LDAPDOMAIN}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

      sed -e "s/##LDAPORG##/$LDAPORG/" etc/new_group.ldiftemplate_template > $RF/new_group.ldiftemplate
      sed -e "s/##LDAPORG##/$LDAPORG/" etc/new_user.ldiftemplate_template > $RF/new_user.ldiftemplate
      sed -e "s/##LDAPORG##/$LDAPORG/" etc/ldap.conf_template > $RF/ldap.conf

      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
          -e "s/##LDAPHOST##/${PREFIX}-${MODULE_NAME}/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/addgroup.sh_template > $RF/addgroup.sh

      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
          -e "s/##LDAPHOST##/${PREFIX}-${MODULE_NAME}/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/adduser.sh_template > $RF/adduser.sh    

      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
          -e "s/##LDAPHOST##/${PREFIX}-${MODULE_NAME}/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/init.sh-template > $RF/init.sh
          
      sed -e "s/##LDAPORG##/$LDAPORG/" \
          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
          -e "s/##LDAPHOST##/${PREFIX}-${MODULE_NAME}/" \
          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/init-core.sh-template > $RF/init-core.sh

      echo "2. Building ${PREFIX}-${MODULE_NAME}..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
  ;;
  "install")
    echo "Installing slapd $PROJECT-${MODULE_NAME} [$LDAPIP]"
    
   #      -p 666:$LDAPPORT \

  ;;
  "start")
      echo "Starting container ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;
  "init")
    echo "Initializing slapd $PROJECT-${MODULE_NAME} [$LDAPIP]"
    docker exec ${PREFIX}-${MODULE_NAME} bash -c /init.sh
    docker exec ${PREFIX}-${MODULE_NAME} bash -c /init-core.sh
    docker exec ${PREFIX}-${MODULE_NAME} bash -c "/usr/local/bin/addgroup.sh users 1000"
    docker exec ${PREFIX}-${MODULE_NAME} bash -c "/usr/local/bin/addgroup.sh report 9990"
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-${MODULE_NAME}"
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
    echo "Cleaning data ${PREFIX}-${MODULE_NAME}"
    rm -R -f $SRV/ldap/
    
  ;;
  "clean")
    echo "Cleaning image ${PREFIX}-${MODULE_NAME}"
    docker $DOCKERARGS rmi ${PREFIX}-${MODULE_NAME}
    rm -r $RF
  ;;
esac
