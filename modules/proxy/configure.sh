#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/proxy-pods.yaml-template > $BUILDMOD_DIR/proxy-pods.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/proxy-svcs.yaml-template > $BUILDMOD_DIR/proxy-svcs.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/proxy-svcs.yaml
      register_module_in_nginx
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/proxy-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/proxy-pods.yaml
  ;;

  "uninstall")
      deregister_module_in_nginx
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/proxy-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

