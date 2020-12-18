#!/bin/bash


case $VERB in

  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svclog
      mkdir_svcdata
      mkdir_svcconf

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/ldap-svcs.yaml-template > $BUILDMOD_DIR/ldap-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##ORGANISATION##,"$LDAP_ORGANISATION", \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          -e s,##FQDN##,$FQDN, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
	  build/ldap-pods.yaml-template > $BUILDMOD_DIR/ldap-pods.yaml

      mkdir_svcdata db
      mkdir_svcdata helper
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
      kubectl cp $BUILDMOD_DIR/helper_init.sh helper:/data/$MODULE_NAME/helper/init.sh
      kubectl cp $BUILDMOD_DIR/helper_adduser.sh helper:/data/$MODULE_NAME/helper/adduser.sh
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/ldap-svcs.yaml
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/ldap-pods.yaml
  ;;

  "init")
      echo "Initialization ${PREFIX}-${MODULE_NAME}" >&2
      kubectl exec --stdin --tty ${PREFIX}-${MODULE_NAME} -- /usr/local/ldap/init.sh
  ;;
    
  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/ldap-pods.yaml
  ;;
    
  "uninstall")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/ldap-svcs.yaml
  ;;
    
  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;
    
esac

