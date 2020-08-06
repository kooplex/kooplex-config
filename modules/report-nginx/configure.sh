#!/bin/bash

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2

      cp build/{Dockerfile,nginx.conf}  $BUILDMOD_DIR
      sed -e "s/##FQDN##/$FQDN/"  build/sites.conf > $BUILDMOD_DIR/sites.conf
      

      echo "2. Building ${PREFIX}-${MODULE_NAME}..."
      docker $DOCKERARGS build -t ${PREFIX}-${MODULE_NAME} -f $BUILDMOD_DIR/Dockerfile $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-${MODULE_NAME} ${MY_REGISTRY}/${PREFIX}-${MODULE_NAME}
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-${MODULE_NAME}


      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
          build/${MODULE_NAME}-pods.yaml-template > $BUILDMOD_DIR/${MODULE_NAME}-pods.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          build/${MODULE_NAME}-svcs.yaml-template > $BUILDMOD_DIR/${MODULE_NAME}-svcs.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/${MODULE_NAME}-svcs.yaml
      register_module_in_nginx
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/${MODULE_NAME}-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/${MODULE_NAME}-pods.yaml
  ;;

  "uninstall")
      deregister_module_in_nginx
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/${MODULE_NAME}-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

