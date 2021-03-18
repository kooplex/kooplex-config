#!/bin/bash


case $VERB in

  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      kubectl create namespace $NS_LDAP
      nfs_provisioner $NS_LDAP $NFS_SERVER $NFS_PATH

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_LDAP, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          build/svc-ldap.yaml-template > $BUILDMOD_DIR/svc-ldap.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_LDAP, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##REQUEST_LOG##,$SERVICELOG_REQUEST, \
          -e s,##REQUEST_CONF##,$SERVICECONF_REQUEST, \
          -e s,##REQUEST_DATA##,$SERVICEDATA_REQUEST, \
	  build/pvc-ldap.yaml-template > $BUILDMOD_DIR/pvc-ldap.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_LDAP, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##ORGANISATION##,"$LDAP_ORGANISATION", \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          -e s,##FQDN##,$FQDN, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
	  build/pod-ldap.yaml-template > $BUILDMOD_DIR/pod-ldap.yaml

      DN="dc=$(echo $FQDN | sed s/\\\./,dc=/g)"
      sed -e s/##LDAPORG##/$DN/ \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          -e s,##GID_USERS##,"$GID_USERS", \
          -e s,##GID_HUB##,"$GID_HUB", \
          -e s,##UID_HUB##,"$UID_HUB", \
          scripts/init.sh-template > $BUILDMOD_DIR/helper_init.sh
      sed -e s/##LDAPORG##/$DN/ \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          scripts/adduser.sh-template > $BUILDMOD_DIR/helper_adduser.sh
      chmod +x $BUILDMOD_DIR/helper_init.sh
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pvc-ldap.yaml
      kubectl apply -f $BUILDMOD_DIR/svc-ldap.yaml
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/pod-ldap.yaml
  ;;

  "init")
      echo "Initialization ${PREFIX}-${MODULE_NAME}" >&2
      kubectl cp -n $NS_LDAP $BUILDMOD_DIR/helper_init.sh ${PREFIX}-${MODULE_NAME}:/usr/local/ldap/init.sh
      kubectl cp -n $NS_LDAP $BUILDMOD_DIR/helper_adduser.sh ${PREFIX}-${MODULE_NAME}:/usr/local/ldap/adduser.sh
      kubectl exec --stdin --tty ${PREFIX}-${MODULE_NAME} -n $NS_LDAP -- /usr/local/ldap/init.sh
  ;;
    
  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/pod-ldap.yaml
  ;;
    
  "uninstall")
      echo "Deleting namespace ${NS_LDAP}" >&2
      kubectl delete namespace $NS_LDAP || true
      kubectl delete storageclass $NS_LDAP || true
      kubectl delete clusterrolebinding crlb-nfs-client-provisioner-runner-$NS_LDAP
  ;;
    
  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;
    
esac

