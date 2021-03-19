#!/bin/bash

DOCKER_HOST=$DOCKERARGS

case $VERB in
    "build")
      echo "Building base image ${PREFIX}-base" >&2
      cp build/Dockerfile-base $BUILDMOD_DIR
      cp scripts/entrypoint.sh $BUILDMOD_DIR
      DN="dc=$(echo $FQDN | sed s/\\\./,dc=/g)"
      sed -e s,##PREFIX##,$PREFIX, \
          -e s/##NS_LDAP##/$NS_LDAP/ \
          -e s/##LDAPORG##/$DN/ \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          conf/nslcd.conf-template > $BUILDMOD_DIR/nslcd.conf
      docker $DOCKERARGS build -t ${PREFIX}-base -f $BUILDMOD_DIR/Dockerfile-base $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-base ${MY_REGISTRY}/${PREFIX}-base
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-base
    ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;


esac
