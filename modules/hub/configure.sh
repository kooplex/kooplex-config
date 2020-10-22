#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svclog
      mkdir_svcdata
      mkdir_svcconf

      mkdir_svcdata _hubcode_
      HELPER_CODE_DIR=/data/hub/_hubcode_
      kubectl exec -it helper -- bash -c "[ -d $HELPER_CODE_DIR/.git ] || git clone -b kubernetes https://github.com/kooplex/kooplex-hub.git $HELPER_CODE_DIR"

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
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
          -e s,##DJANGO_SECRET_KEY##,$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g'), \
          -e s,##HUB_MYSQL_ROOTPW##,$HUB_MYSQL_ROOTPW, \
          -e s,##HUBDB_USER##,$HUBUSER, \
          -e s,##HUBDB_PW##,$HUBUSER_PW, \
	  build/hub-pods.yaml-template > $BUILDMOD_DIR/hub-pods.yaml

      sed -e s,##PREFIX##,${PREFIX}, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##HOME_DIR##,${HOME_DIR}, \
          -e s,##HOME_QUOTA##,${HOME_QUOTA}, \
          -e s,##GARBAGE_DIR##,${GARBAGE_DIR}, \
          -e s,##GARBAGE_QUOTA##,${GARBAGE_QUOTA}, \
          -e s,##PROJECT_DIR##,${PROJECT_DIR}, \
          -e s,##PROJECT_QUOTA##,${PROJECT_QUOTA}, \
          -e s,##REPORT_DIR##,${REPORT_DIR}, \
          -e s,##REPORT_QUOTA##,${REPORT_QUOTA}, \
          -e s,##CACHE_DIR##,${CACHE_DIRS}, \
          -e s,##CACHE_QUOTA##,${CACHE_QUOTA}, \
          build/pv-hub.yaml-template > $BUILDMOD_DIR/pv-hub.yaml
      sed -e s,##PREFIX##,${PREFIX}, \
          -e s,##HOME_USERQUOTA##,${HOME_USERQUOTA}, \
          -e s,##GARBAGE_QUOTA##,${GARBAGE_QUOTA}, \
          -e s,##PROJECT_PROJECTQUOTA##,${PROJECT_PROJECTQUOTA}, \
          -e s,##REPORT_REPORTQUOTA##,${REPORT_REPORTQUOTA}, \
          -e s,##CACHE_USERQUOTA##,${CACHE_USERQUOTA}, \
          build/pvc-hub.yaml-template > $BUILDMOD_DIR/pvc-hub.yaml
      kubectl apply -f $BUILDMOD_DIR/pv-hub.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-hub.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hub-svcs.yaml
      register_module_in_nginx
      register_module_in_hydra
      echo "Store default.conf in configmap" >&2
      ( cat <<EOF1
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $PREFIX-hub
  namespace: default
data:
  client: $CLIENT
  secret: $SECRET
EOF1
      ) \
              > $BUILDMOD_DIR/confmap.yaml
      kubectl apply -f $BUILDMOD_DIR/confmap.yaml
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hub-pods.yaml
  ;;

  "init")
	  kubectl exec -it ${PREFIX}-${MODULE_NAME} -- python3 /kooplexhub/kooplexhub/manage.py makemigrations
	  kubectl exec -it ${PREFIX}-${MODULE_NAME} -- python3 /kooplexhub/kooplexhub/manage.py migrate
  ;;

  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hub-pods.yaml
  ;;

  "uninstall")
      deregister_module_in_nginx
      deregister_module_in_hydra
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hub-svcs.yaml || true
      kubectl delete -f $BUILDMOD_DIR/pvc-hub.yaml || true
      kubectl delete -f $BUILDMOD_DIR/pv-hub.yaml
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;

esac

