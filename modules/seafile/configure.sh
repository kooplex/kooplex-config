#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
#FIXME: all seafile persistent directories are handled together, split conf/data/log
#      mkdir_svcconf
#      mkdir_svclog
      mkdir_svcdata
      CONFD=$MODDATA_DIR/seafile/seafile/conf/
      _mkdir $CONFD

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##FQDN##,$FQDN, \
	  -e s,##SEAFILE_MYSQL_ROOTPW##,$SEAFILEDB_PW, \
	  -e s,##SEAFILE_ADMIN##,$SEAFILEADMIN, \
	  -e s,##SEAFILE_ADMINPW##,$SEAFILEADMIN_PW, \
	  build/seafile-pods.yaml-template > $BUILDMOD_DIR/seafile-pods.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/seafile-svcs.yaml-template > $BUILDMOD_DIR/seafile-svcs.yaml

      sed -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s,##PREFIX##,$PREFIX, \
          -e s,##FQDN##,$FQDN, \
          -e s,##SEAFILEDB_PW##,$SEAFILEDB_PW, \
          -e s,##URL_HYDRA##,$URL_HYDRA, \
          -e s,##HYDRA_CLIENTID##,$HYDRA_SEAHUBCLIENTID, \
          -e s,##DJANGO_SECRET_KEY##,$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g'), \
          -e s,##HYDRA_CLIENTSECRET##,$HYDRA_SEAHUBCLIENTSECRET, \
	  conf/seahub_settings.py-template > $CONFD/seahub_settings.py
  ;;

  "install")
      sed -e s,##PREFIX##,$PREFIX, \
          conf/nginx-${MODULE_NAME}-template > $SERVICECONF_DIR/nginx/conf.d/sites-enabled/${MODULE_NAME}
      restart_nginx
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/seafile-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/seafile-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/seafile-pods.yaml
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/seafile-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

