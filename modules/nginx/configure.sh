#!/bin/bash


NGINX_KEYS=$FQDN_CERT

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svcconf
      mkdir_svclog

      echo "Store certificates" >&2
      KEY=$(cat $KEYFILE | base64 -w 0)
      CERT=$(cat $CERTFILE | base64 -w 0)
      cat build/tls-secret.yaml-template | \
	      sed -e s,##PREFIX##,$PREFIX, \
	          -e s,##KEY##,$KEY, \
	          -e s,##CERT##,$CERT, \
              > $BUILDMOD_DIR/tls-secret.yaml
      kubectl apply -f $BUILDMOD_DIR/tls-secret.yaml

      echo "Store default.conf in configmap" >&2
      ( cat <<EOF1
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $PREFIX-nginx
  namespace: default
data:
  default: |
EOF1
        sed -e s,##FQDN##,$FQDN, \
	  -e s,^,"    ", \
	  conf/default.conf-template
  cat <<EOF2
  pg_404: |
EOF2
        sed s,^,"    ", conf/custom_404.html

  cat <<EOF3
  pg_502: |
EOF3
        sed s,^,"    ", conf/custom_502.html

      ) \
              > $BUILDMOD_DIR/confmap.yaml
      kubectl apply -f $BUILDMOD_DIR/confmap.yaml
      
      echo "Create pod/service descriptions" >&2
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/nginx-pods.yaml-template > $BUILDMOD_DIR/nginx-pods.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##EXTERNALIP##,$EXTERNALIP, \
	  build/nginx-svcs.yaml-template > $BUILDMOD_DIR/nginx-svcs.yaml
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/nginx-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/nginx-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/nginx-pods.yaml
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/nginx-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

