#!/bin/bash

#FIXME: ingress

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2

      kubectl create namespace $NS_PROXY

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,${NS_PROXY}, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/pod-proxy.yaml-template > $BUILDMOD_DIR/pod-proxy.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,${NS_PROXY}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/svc-proxy.yaml-template > $BUILDMOD_DIR/svc-proxy.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/svc-proxy.yaml
      #register_module_in_nginx
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pod-proxy.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/pod-proxy.yaml
  ;;

  "uninstall")
      #deregister_module_in_nginx
      echo "Deleting namespace ${NS_PROXY}" >&2
      kubectl delete namespace $NS_PROXY
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;

esac

