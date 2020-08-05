#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svclog
      mkdir_svcdata
      mkdir_svcconf

      SECRET_DIR=$MODCONF_DIR/secrets
      _mkdir $SECRET_DIR
      touch $SECRET_DIR/${PREFIX}-${MODULE_NAME}-hydra.secret
      
      CODE_DIR=$MODDATA_DIR/_hubcode_
      _mkdir $CODE_DIR
      if [ -d $CODE_DIR/.git ] ; then
          echo "Code already cloned in folder $CODE_DIR. Pull if necessary"
      else
          git clone https://github.com/kooplex/kooplex-hub.git $CODE_DIR
      fi

      sed -e s,##PREFIX##,${PREFIX}, \
          build/Dockerfile.hub-template > $BUILDMOD_DIR/Dockerfile.hub

      cp scripts/runserver.sh $BUILDMOD_DIR
      cp $KUBE_CONFIG $BUILDMOD_DIR/kubeconfig
      docker $DOCKERARGS build -t ${PREFIX}-hub -f $BUILDMOD_DIR/Dockerfile.hub $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-hub ${MY_REGISTRY}/${PREFIX}-hub
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-hub

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/hub-svcs.yaml-template > $BUILDMOD_DIR/hub-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
          -e s,##DJANGO_SECRET_KEY##,$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g'), \
          -e s,##HUB_MYSQL_ROOTPW##,$HUB_MYSQL_ROOTPW, \
          -e s,##HUBDB_USER##,$HUBUSER, \
          -e s,##HUBDB_PW##,$HUBUSER_PW, \
	  build/hub-pods.yaml-template > $BUILDMOD_DIR/hub-pods.yaml

#      cp $BUILDDIR/CA/rootCA.crt $RF/

      _mkdir $HOME_DIR
      _mkdir $PROJECT_DIR
      _mkdir $REPORT_DIR
      _mkdir $REPORT_PREPARE_DIR
      _mkdir $GARBAGE_DIR
      _mkdir $VERSIONCONTROL_DIR
      _mkdir $FILESYNC_DIR
      sed -e s,##PREFIX##,${PREFIX}, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##HOME_DIR##,${HOME_DIR}, \
          -e s,##GARBAGE_DIR##,${GARBAGE_DIR}, \
          -e s,##PROJECT_DIR##,${PROJECT_DIR}, \
          -e s,##REPORT_DIR##,${REPORT_DIR}, \
          -e s,##REPORT_PREPARE_DIR##,${REPORT_PREPARE_DIR}, \
          -e s,##VERSIONCONTROL_DIR##,${VERSIONCONTROL_DIR}, \
          -e s,##FILESYNC_DIR##,${FILESYNC_DIR}, \
          build/pv-hub.yaml-template > $BUILDMOD_DIR/pv-hub.yaml
      sed -e s,##PREFIX##,${PREFIX}, \
          build/pvc-hub.yaml-template > $BUILDMOD_DIR/pvc-hub.yaml
      kubectl apply -f $BUILDMOD_DIR/pv-hub.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-hub.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hub-svcs.yaml
      register_module_in_nginx
      register_module_in_hydra
      cp -a $SECRETS_FILE $SERVICECONF_DIR/$MODULE_NAME/secrets
      echo "Secrets copied" >&2
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hub-pods.yaml
  ;;

  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hub-pods.yaml
  ;;

  "uninstall")
      deregister_module_in_nginx
      deregister_module_in_hydra
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hub-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

