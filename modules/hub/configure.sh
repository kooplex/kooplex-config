#!/bin/bash


case $VERB in
   "buildimage")
      echo "1. Build image ${PREFIX}-${MODULE_NAME}..." >&2
      sed -e s,##PREFIX##,${PREFIX}, \
          build/Dockerfile.hub-template > $BUILDMOD_DIR/Dockerfile.hub

      cp scripts/runserver.sh $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-hub -f $BUILDMOD_DIR/Dockerfile.hub $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-hub ${MY_REGISTRY}/${PREFIX}-hub
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-hub

  ;;

  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      kubectl create namespace $NS_HUB || true
      pv_local service $HUB_VOLUME_REQUEST $HUB_VOLUME_PATH $WORKER_NODES
      pvc_local service ${NS_HUB} ${HUB_VOLUME_REQUEST} local-storage
      pv_local userdata $USERDATA_VOLUME_REQUEST $USERDATA_VOLUME_PATH $WORKER_NODES
      pvc_local userdata ${NS_HUB} ${USERDATA_VOLUME_REQUEST} local-storage
      pv_local cache $USERCACHE_VOLUME_REQUEST $USERCACHE_VOLUME_PATH $WORKER_NODES
      pvc_local cache ${NS_HUB} ${USERCACHE_VOLUME_REQUEST} local-storage
      ingress service $NS_HUB hub ${PREFIX}-${MODULE_NAME} hub 80
      configmap_ldap ${NS_HUB} "dc=$(echo $FQDN | sed s/\\\./,dc=/g)"

      cp $KUBE_CONFIG $BUILDMOD_DIR/kubeconfig

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_HUB, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/svc-hub.yaml-template > $BUILDMOD_DIR/svc-hub.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_HUB, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
          -e s,##DJANGO_SECRET_KEY##,$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g'), \
          -e s,##HUB_MYSQL_ROOTPW##,$HUB_MYSQL_ROOTPW, \
          -e s,##HUBDB_USER##,$HUBUSER, \
          -e s,##HUBDB_PW##,$HUBUSER_PW, \
          -e s,##LDAP_ADMIN_PASSWORD##,$LDAP_ADMIN_PASSWORD, \
	  build/pod-hub.yaml-template > $BUILDMOD_DIR/pod-hub.yaml

  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pv-service.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-service.yaml
      kubectl apply -f $BUILDMOD_DIR/pv-userdata.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-userdata.yaml
      kubectl apply -f $BUILDMOD_DIR/pv-cache.yaml
      kubectl apply -f $BUILDMOD_DIR/pvc-cache.yaml
      kubectl apply -f $BUILDMOD_DIR/svc-hub.yaml
      kubectl apply -f $BUILDMOD_DIR/ingress-service.yaml
      kubectl apply -f $BUILDMOD_DIR/configmap-nslcd.yaml
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pod-hub.yaml
  ;;

  "init")
      kubectl wait --for=condition=Ready pod/${PREFIX}-${MODULE_NAME} -n $NS_HUB
      kubectl exec -it ${PREFIX}-ldap -n $NS_LDAP -- /usr/local/ldap/adduser.sh hub $UID_HUB $GID_HUB
      kubectl exec -it ${PREFIX}-${MODULE_NAME} -n $NS_HUB -- python3 /kooplexhub/kooplexhub/manage.py makemigrations
      kubectl exec -it ${PREFIX}-${MODULE_NAME} -n $NS_HUB -- python3 /kooplexhub/kooplexhub/manage.py migrate
  ;;

  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/pod-hub.yaml
  ;;

  "uninstall")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/ingress-service.yaml || true
      kubectl delete namespace $NS_HUB || true
      kubectl delete -f $BUILDMOD_DIR/pv-service.yaml || true
      kubectl delete -f $BUILDMOD_DIR/pv-userdata.yaml || true
      kubectl delete -f $BUILDMOD_DIR/pv-cache.yaml || true
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;

esac

