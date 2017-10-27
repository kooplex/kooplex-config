#!/bin/bash

RF=$BUILDDIR/owncloud
mkdir -p $RF

case $VERB in
  "build")
    echo "Building image ${PROJECT}-owncloud"
    sed -e "s/##DOMAIN##/${OUTERHOST}/" \
        -e "s/##OCADMIN##/ocadmin/" \
        -e "s/##OCADMINPW##/${DUMMYPASS}/" \
        -e "s/##DBROOTPW##/${DUMMYPASS}/" \
        -e "s/##DBUSER##/owncloud/" \
        -e "s/##DBUSERPW##/${DUMMYPASS}/" \
        -e "s/##VOLUMEOC##/${PROJECT}-owncloud/" \
        -e "s/##VOLUMEOCDB##/${PROJECT}-owncloud-mysql/" \
        -e "s/##VOLUMEOCREDIS##/${PROJECT}-owncloud-redis/" \
        -e "s/##NETWORK##/${PROJECT}-net/" \
        -e "s/##NETWORKPRIVATE##/owncloud-net/" \
        -e "s/##CTROC##/${PROJECT}-owncloud/" \
        -e "s/##CTROCDB##/${PROJECT}-owncloud-mysql/" \
        -e "s/##CTROCREDIS##/${PROJECT}-owncloud-redis/" \
        docker-compose.yml_template > $RF/docker-compose.yml
    docker-compose -f $RF/docker-compose.yml build
    sed -e "s/##LDAPORG##/${LDAPORG}/" \
        -e "s/##LDAPIP##/${LDAPIP}/" \
        -e "s/##SECRET##/${DUMMYPASS}/" \
        -e "s/##OWNCLOUDIP##/${OWNCLOUDIP}/" \
        -e "s/##NGINXIP##/${NGINXIP}/" \
        -e "s/##OUTERHOST##/${OUTERHOST}/" \
        -e "s/##INNERHOST##/${INNERHOST}/" \
        -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
        setup_ldap.sh_template > $RF/setup_ldap.sh
  ;;

  "install")
    echo "Starting owncloud ${PROJECT}-owncloud [$OWNCLOUDIP]"
    docker-compose -f $RF/docker-compose.yml create
  ;;

  "start")
    echo "Starting owncloud ${PROJECT}-owncloud [$OWNCLOUDIP]"
    docker-compose -f $RF/docker-compose.yml up -d
  ;;

  "init")
    echo "Configuring ${PROJECT}-owncloud [$OWNCLOUDIP]"
    docker cp $RF/setup_ldap.sh ${PROJECT}-owncloud:/setup_ldap.sh
    docker exec -t ${PROJECT}-owncloud chmod +x /setup_ldap.sh
    docker exec -t ${PROJECT}-owncloud su www-data -c /setup_ldap.sh
  ;;

  "stop")
    echo "Stopping owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
    docker-compose -f $RF/docker-compose.yml stop
  ;;

  "remove")
  #  echo "Removing owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
  #  docker-compose -f $RF/docker-compose.yml stop
  ;;

  "purge")
  #  echo "Purging owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
  #  rm -R -f $SRV/ownCloud
  ;;

  "clean")
  ;;

esac
