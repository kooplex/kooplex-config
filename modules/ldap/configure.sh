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
          -e s,##ORGANIZATION##,"$LDAP_ORGANIZATION", \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          -e s,##FQDN##,$FQDN, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
	  build/ldap-pods.yaml-template > $BUILDMOD_DIR/ldap-pods.yaml

      _mkdir $MODDATA_DIR/db
      _mkdir $MODDATA_DIR/helper
      DN="dc=$(echo $FQDN | sed s/\\\./,dc=/g)"
      sed -e s/##LDAPORG##/$DN/ \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          scripts/init.sh-template > $MODDATA_DIR/helper/init.sh
      sed -e s/##LDAPORG##/$DN/ \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          scripts/adduser.sh-template > $MODDATA_DIR/helper/adduser.sh
  ;;

  "install")
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/ldap-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/ldap-pods.yaml
  ;;


  "init")
    ##echo "Initializing slapd $PROJECT-ldap [$LDAPIP]"
    ##docker exec ${PREFIX}-ldap bash -c /init.sh
    ##docker exec ${PREFIX}-ldap bash -c /init-core.sh
    ##docker exec ${PREFIX}-ldap bash -c "/usr/local/bin/addgroup.sh users 1000"
    ##docker exec ${PREFIX}-ldap bash -c "/usr/local/bin/addgroup.sh report 9990"
  ;;
    
  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/ldap-pods.yaml
  ;;
    
  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/ldap-svcs.yaml
  ;;
    
  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;
    
esac

