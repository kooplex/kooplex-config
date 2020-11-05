#!/bin/bash

case $VERB in
  "build")
      echo "1. Building ${PREFIX}-impersonator..." >&2
      mkdir_svclog

      cp scripts/02-api-start.sh $BUILDMOD_DIR
      cp scripts/{common.py,seafile_functions.py,git_functions.py,api.py} $BUILDMOD_DIR
      sed -e "s/##PREFIX##/${PREFIX}/" \
	      build/Dockerfile-template \
	      > $BUILDMOD_DIR/Dockerfile

      docker $DOCKERARGS build -t ${PREFIX}-impersonator -f $BUILDMOD_DIR/Dockerfile $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-impersonator ${MY_REGISTRY}/${PREFIX}-impersonator
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-impersonator

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          build/impersonator-svcs.yaml-template > $BUILDMOD_DIR/impersonator-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##IMAGE##,$MY_REGISTRY/${PREFIX}-impersonator, \
          build/impersonator-pods.yaml-template > $BUILDMOD_DIR/impersonator-pods.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/impersonator-svcs.yaml

  ;;

  "start")  
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/impersonator-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/impersonator-pods.yaml
  ;;

  "uninstall")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/impersonator-svcs.yaml || true
  ;;
    
  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;

esac

