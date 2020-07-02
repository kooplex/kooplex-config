#!/bin/bash


case $VERB in

  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svcdata

      if [ -d $MODDATA_DIR/.git ] ; then
          echo "Manuals already cloned in folder $MODDATA_DIR. Pull if necessary"
      else
          git clone https://github.com/kooplex/Manual.git $MODDATA_DIR
      fi

      cp build/Dockerfile $BUILDMOD_DIR
      cp scripts/entrypoint.sh $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-manual -f $BUILDMOD_DIR/Dockerfile $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-manual ${MY_REGISTRY}/${PREFIX}-manual
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-manual

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/manual-svcs.yaml-template > $BUILDMOD_DIR/manual-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
	  build/manual-pods.yaml-template > $BUILDMOD_DIR/manual-pods.yaml
  ;;

  "install")
      sed -e s,##PREFIX##,$PREFIX, \
          conf/nginx-${MODULE_NAME}-template > $SERVICECONF_DIR/nginx/conf.d/sites-enabled/${MODULE_NAME}
      restart_nginx
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/manual-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/manual-pods.yaml
  ;;


  "init")
  ;;
    
  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/manual-pods.yaml
  ;;
    
  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/manual-svcs.yaml
  ;;
    
  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;
    
esac
