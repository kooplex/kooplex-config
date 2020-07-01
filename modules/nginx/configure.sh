#!/bin/bash


NGINX_KEYS=$FQDN_CERT

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svcconf
      mkdir_svclog
      mkdir_svcdata
      _mkdir $MODCONF_DIR/conf.d/sites-enabled
      _mkdir $MODCONF_DIR/keys

      cp $KEYFILE $MODCONF_DIR/keys/${PREFIX}.key
      cp $CERTFILE $MODCONF_DIR/keys/${PREFIX}.crt
      cp conf/custom* $MODDATA_DIR/

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/nginx-pods.yaml-template > $BUILDMOD_DIR/nginx-pods.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##EXTERNALIP##,$EXTERNALIP, \
	  build/nginx-svcs.yaml-template > $BUILDMOD_DIR/nginx-svcs.yaml

      sed -e s,##CERT##,${PREFIX}.crt, \
          -e s,##KEY##,${PREFIX}.key, \
          -e s,##PREFIX##,${PREFIX}, \
          -e s,##OUTERHOST##,$FQDN, \
          -e s,##OUTERPORT##,$OUTERHOSTPORT, \
	  conf/default.conf-template > $MODCONF_DIR/conf.d/default.conf
  ;;

  "install")
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/nginx-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/nginx-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/nginx-pods.yaml
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/nginx-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

