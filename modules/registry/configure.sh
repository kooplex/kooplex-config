#!/bin/bash

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2

      kubectl create namespace $NS_REGISTRY
      kubectl create secret tls tls-$NS_REGISTRY -n $NS_REGISTRY \
              --cert=$CERTFILE \
              --key=$KEYFILE

      sed -e s,##PREFIX##,$PREFIX, \
	  -e s,##REGISTRY##,$NS_REGISTRY, \
	  -e s,##REGISTRY_LABEL##,$NS_REGISTRY, \
          -e s,##NFS_SERVER_IMAGE##,$NFS_SERVER_IMAGE, \
          -e s,##NFS_FOLDER_IMAGE##,$NFS_PATH_IMAGE, \
	  build/pv-registry.yaml-template > $BUILDMOD_DIR/pv-registry.yaml

      sed -e s,##PREFIX##,$PREFIX, \
	  -e s,##NS##,$NS_REGISTRY, \
	  -e s,##REGISTRY##,$NS_REGISTRY, \
	  -e s,##REGISTRY_LABEL##,$NS_REGISTRY, \
	  build/pvc-registry.yaml-template > $BUILDMOD_DIR/pvc-registry.yaml

      kubectl apply -f $BUILDMOD_DIR/pv-registry.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-registry.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,${NS_REGISTRY}, \
	  -e s,##REGISTRY##,$NS_REGISTRY, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/pod-registry.yaml-template > $BUILDMOD_DIR/pod-registry.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,${NS_REGISTRY}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##EXTERNALIP##,$EXTERNALIP, \
	  build/svc-registry.yaml-template > $BUILDMOD_DIR/svc-registry.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/svc-registry.yaml
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pod-registry.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/pod-proxy.yaml
  ;;

  "uninstall")
      echo "Deleting namespace ${NS_REGISTRY}" >&2
      kubectl delete namespace $NS_REGISTRY
      echo "Deleting persistent volume pv-${NS_REGISTRY}" >&2
      kubectl delete -f $BUILDMOD_DIR/pv-registry.yaml
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

esac

