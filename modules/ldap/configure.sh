#!/bin/bash


case $VERB in

  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
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

##      sed -e "s/##LDAPORG##/$LDAPORG/" etc/new_group.ldiftemplate_template > $RF/new_group.ldiftemplate
##      sed -e "s/##LDAPORG##/$LDAPORG/" etc/new_user.ldiftemplate_template > $RF/new_user.ldiftemplate
##      sed -e "s/##LDAPORG##/$LDAPORG/" etc/ldap.conf_template > $RF/ldap.conf
##
##      sed -e "s/##LDAPORG##/$LDAPORG/" \
##          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
##          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
##          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/addgroup.sh_template > $RF/addgroup.sh
##      sed -e "s/##LDAPORG##/$LDAPORG/" \
##          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
##          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
##          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/adduser.sh_template > $RF/adduser.sh
##          
##
##      sed -e "s/##LDAPORG##/$LDAPORG/" \
##          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
##          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
##          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/init.sh-template > $RF/init.sh
##          
##      sed -e "s/##LDAPORG##/$LDAPORG/" \
##          -e "s/##SLAPD_PASSWORD##/$HUBLDAP_PW/" \
##          -e "s/##LDAPHOST##/${PREFIX}-ldap/" \
##          -e "s/##LDAPPORT##/$LDAPPORT/" scripts/init-core.sh-template > $RF/init-core.sh
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

