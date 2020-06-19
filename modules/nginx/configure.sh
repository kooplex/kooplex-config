#!/bin/bash


NGINX_KEYS=$FQDN_CERT

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."
      mkdir_svcconf
      mkdir_svclog
      mkdir_svcdata
      _mkdir $MODCONF_DIR/conf.d/sites-enabled
      _mkdir $MODCONF_DIR/keys

      cp $KEYFILE $MODCONF_DIR/keys/${PREFIX}.key
      cp $CERTFILE $MODCONF_DIR/keys/${PREFIX}.crt
      cp etc/custom* $MODDATA_DIR/

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##EXTERNALIP##,$EXTERNALIP, build/nginx.yaml-template \
          > $BUILDMOD_DIR/nginx.yaml

      sed -e s,##CERT##,${PREFIX}.crt, \
          -e s,##KEY##,${PREFIX}.key, \
          -e s,##PREFIX##,${PREFIX}, \
          -e s,##OUTERHOST##,$FQDN, \
          -e s,##OUTERPORT##,$OUTERHOSTPORT, etc/default.conf-template \
          > $MODCONF_DIR/conf.d/default.conf
  ;;

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-${MODULE_NAME}"
       kubectl apply -f $BUILDMOD_DIR/nginx.yaml
  ;;


  "stop")
      echo "Stopping containers of ${PREFIX}-${MODULE_NAME}"
      kubectl delete -f $BUILDMOD_DIR/nginx.yaml
  ;;

  "remove")
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" 
      rm -R -f $BUILDMOD_DIR
  ;;

esac

