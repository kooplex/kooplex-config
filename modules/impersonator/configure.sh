#!/bin/bash

MODULE_NAME=impersonator
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

IMP_CONF=$CONF_DIR/${MODULE_NAME}

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-impersonator..."
     
     mkdir -p $IMP_CONF
     docker $DOCKERARGS volume create -o type=none -o device=$IMP_CONF -o o=bind ${PREFIX}-impersonator-conf

###  printf "$(ldap_ldapconfig)\n\n" > ${RF}/ldap.conf

  printf "$(ldap_nsswitchconfig)\n\n" > ${IMP_CONF}/nsswitch.conf
  printf "$(ldap_nslcdconfig)\n\n" > ${IMP_CONF}/nslcd.conf
  chown root ${IMP_CONF}/nslcd.conf
  chmod 0600 ${IMP_CONF}/nslcd.conf

    if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
      IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
     else
      #IMAGE_NAME=${PREFIX}-${MODULE_NAME}
      IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}

             echo "2. Building ${PREFIX}-${MODULE_NAME}.."
             cp scripts/01-nslcd-start.sh $RF
             cp scripts/02-api-start.sh $RF
             cp scripts/{entrypoint.sh,common.py,seafile_functions.py,git_functions.py,api.py} $RF
             sed -e "s/##PREFIX##/${PREFIX}/g"  Dockerfile-template > $RF/Dockerfile
             docker $DOCKER_HOST build -f $RF/Dockerfile -t ${IMAGE_NAME} $RF
        if [ ${IMAGE_REPOSITORY_URL} ]; then
              docker $DOCKERARGS push ${IMAGE_NAME}
        fi 
             #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    fi

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s,##IMAGE_NAME##,${IMAGE_NAME}," docker-compose.yml-template > $DOCKER_COMPOSE_FILE
###      cp etc/nsswitch.conf $RF
###      cp scripts/create_user_userdb.sh $RF
##      cp scripts/03-startinotify.sh $RF
##      cp scripts/04-start-seafileclient.sh $RF
###      sed -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
###          -e "s/##PREFIX##/$PREFIX/" \
###          -e "s/##MINUID##/$MINUID/" scripts/patch-davfs.sh-template > $RF/patch-davfs.sh
###      sed -e "s/##LDAPPORT##/$LDAPPORT/" \
###          -e "s/##LDAPBINDROOT##/cn=admin,$LDAPORG/" \
###          -e "s/##LDAPBASE##/$LDAPORG/" \
###          -e "s/##LDAPBINDROOTPW##/$DUMMYPASS/"  scripts/patch-gitconfig.sh_template > $RF/patch-gitconfig.sh
###      sed -e "s/##LDAPPORT##/$LDAPPORT/" \
###          -e "s/##LDAPORG##/$LDAPORG/" \
###          -e "s/##LDAPPW##/$LDAPPW/" \
###          -e "s/##PREFIX##/$PREFIX/" \
###          -e "s/##INNERHOST##/$INNERHOST/" \
###          -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
###          -e "s/##GITLABADMINPW##/${GITLABADMINPW}/" \
###          -e "s/##LDAPBINDPW##/$DUMMYPASS/" scripts/create_admin.sh-template > $RF/create_admin.sh
###      sed -e "s/##LDAPURI##/ldap:\/\/$LDAPSERV/" \
###          -e "s/##LDAPBASE##/ou=users,$LDAPORG/" \
###          -e "s/##LDAPBINDDN##/cn=admin,$LDAPORG/" \
###          -e "s/##LDAPBINDPW##/$LDAPPW/" \
###          -e "s/##LDAPBINDROOT##/cn=admin,$LDAPORG/" \
###          -e "s/##LDAPBINDROOTPW##/$LDAPPW/" etc/nslcd.conf_template > $RF/nslcd.conf
###      sed -e "s/##OWNCLOUDURL##/http:\/\/${PREFIX}-nginx\/ownCloud\/ocs\/v1.php\/apps\/files_sharing\/api\/v1\/shares/" \
###          -e "s/##WEBDAVPATTERN##/http:..${PREFIX}-nginx.ownCloud.remote.php.webdav./" scripts/share.sh_template > $RF/share.sh
###      chmod 0600 $RF/nslcd.conf
###      chmod 0755 $RF/share.sh
###      chmod 0755 $RF/patch-gitconfig.sh
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

#    docker $DOCKERARGS volume rm ${PREFIX}-git
    docker $DOCKERARGS volume rm ${PREFIX}-impersonator-conf
  ;;

  "clean")
    rm -r $IMP_CONF
  ;;
esac

