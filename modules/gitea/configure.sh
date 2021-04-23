#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      kubectl create namespace $NS_GITEA || true
      pv_local service $GITEA_VOLUME_REQUEST $GITEA_VOLUME_PATH $WORKER_NODES
      pvc_local service ${NS_GITEA} ${GITEA_VOLUME_REQUEST} local-storage
      ingress service $NS_GITEA gitea ${PREFIX}-${MODULE_NAME} gitea 3000

      ROOTURL=${REWRITEPROTO}://${FQDN}/gitea
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_GITEA, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##EXTERNALIP##,$EXTERNALIP, \
          build/svc-gitea.yaml-template > $BUILDMOD_DIR/svc-gitea.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_GITEA, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##ROOTURL##,$ROOTURL, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  -e s,##GITEA_MYSQL_ROOTPW##,$GITEADB_PW, \
	  -e s,##GITEADB_USER##,$GITEAUSER, \
	  -e s,##GITEADB_PW##,$GITEAUSER_PW, \
          build/pod-gitea.yaml-template > $BUILDMOD_DIR/pod-gitea.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##FQDN##,$FQDN, \
          -e s,##ROOTURL##,$ROOTURL, \
          -e s,##GITEADB_ROOTPW##,$GITEAADMINPW, \
          -e s,##GITEADB##,$GITEADB, \
          -e s,##GITEADB_USER##,$GITEAUSER, \
          -e s,##GITEADB_PW##,$GITEAUSER_PW, \
	  conf/app.ini-template > $BUILDMOD_DIR/app.ini
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pv-service.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-service.yaml
      kubectl apply -f $BUILDMOD_DIR/svc-gitea.yaml
      kubectl apply -f $BUILDMOD_DIR/ingress-service.yaml
      ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pod-gitea.yaml
  ;;

  "init")
      echo "Initiaizing services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl wait --for=condition=Ready pod/${PREFIX}-${MODULE_NAME} -n $NS_GITEA
      kubectl cp $BUILDMOD_DIR/app.ini -n $NS_GITEA ${PREFIX}-${MODULE_NAME}:/data/gitea/conf/app.ini
      kubectl exec -n $NS_GITEA ${PREFIX}-${MODULE_NAME} -- mkdir -p /data/gitea/templates/
      kubectl cp template/home.tmpl -n $NS_GITEA ${PREFIX}-${MODULE_NAME}:/data/gitea/templates/
      kubectl cp template/user -n $NS_GITEA ${PREFIX}-${MODULE_NAME}:/data/gitea/templates/
      echo "WARNING: restart manually!" >&2
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/pod-gitea.yaml
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

