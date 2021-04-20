#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      kubectl create namespace $NS_SEAFILE || true
      pv_local service $SEAFILE_VOLUME_REQUEST $SEAFILE_VOLUME_PATH $WORKER_NODES
      pvc_local service ${NS_SEAFILE} ${SEAFILE_VOLUME_REQUEST} local-storage
      ingress service $NS_SEAFILE seafile ${PREFIX}-${MODULE_NAME} seafile 80

      ###FIXME: cp -r patch-for-7.0.4/ $BUILDMOD_DIR/

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_SEAFILE, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/svc-seafile.yaml-template > $BUILDMOD_DIR/svc-seafile.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_SEAFILE, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##FQDN##,$FQDN, \
	  -e s,##SEAFILE_MYSQL_ROOTPW##,$SEAFILEDB_PW, \
	  -e s,##SEAFILE_ADMIN##,$SEAFILEADMIN, \
	  -e s,##SEAFILE_ADMINPW##,$SEAFILEADMIN_PW, \
	  build/pod-seafile.yaml-template > $BUILDMOD_DIR/pod-seafile.yaml

   #   cp build/Dockerfile.seafile_pw $BUILDMOD_DIR
   #   cp build/set_password.py $BUILDMOD_DIR
   #   cp build/requirements.txt $BUILDMOD_DIR
   #   docker $DOCKERARGS build -t ${PREFIX}-seafile_pw -f $BUILDMOD_DIR/Dockerfile.seafile_pw $BUILDMOD_DIR
   #   docker $DOCKERARGS tag ${PREFIX}-seafile_pw ${MY_REGISTRY}/${PREFIX}-seafile_pw
   #   docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-seafile_pw
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pv-service.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-service.yaml
      kubectl apply -f $BUILDMOD_DIR/svc-seafile.yaml
      kubectl apply -f $BUILDMOD_DIR/ingress-service.yaml
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pod-seafile.yaml
  ;;

  "init")
      echo "Initiaizing services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl wait --for=condition=Ready pod/${PREFIX}-${MODULE_NAME} -n $NS_SEAFILE
      sed -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s,##PREFIX##,$PREFIX, \
          -e s,##FQDN##,$FQDN, \
          -e s,##SEAFILEDB_PW##,$SEAFILEDB_PW, \
          -e s,##URL_HYDRA##,$REWRITEPROTO://$FQDN/hydra, \
          -e s,##HYDRA_CLIENTID##,${CLIENT}, \
          -e s,##DJANGO_SECRET_KEY##,$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g'), \
          -e s,##HYDRA_CLIENTSECRET##,$SECRET, \
      conf/seahub_settings.py-template > $BUILDMOD_DIR/seahub_settings.py
      kubectl cp $BUILDMOD_DIR/seahub_settings.py -n $NS_SEAFILE ${PREFIX}-${MODULE_NAME}:/opt/seafile/seafile-server-8.0.4/seahub/seahub/settings.py
      echo "WARNING: restart manually!" >&2
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/pod-seafile.yaml
  ;;

  "uninstall")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/ingress-service.yaml || true
      kubectl delete namespace $NS_SEAFILE || true
      kubectl delete -f $BUILDMOD_DIR/pv-service.yaml || true
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;

esac

