#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
#      mkdir_svcconf
#      mkdir_svclog
      mkdir_svcdata

      ROOTURL=${REWRITEPROTO}://${FQDN}/gitea
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          build/gitea-svcs.yaml-template > $BUILDMOD_DIR/gitea-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##ROOTURL##,$ROOTURL, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  -e s,##GITEA_MYSQL_ROOTPW##,$GITEADB_PW, \
	  -e s,##GITEADB_USER##,$GITEAUSER, \
	  -e s,##GITEADB_PW##,$GITEAUSER_PW, \
          build/gitea-pods.yaml-template > $BUILDMOD_DIR/gitea-pods.yaml

      CONFDIR=$MODDATA_DIR/gitea/gitea/conf
      _mkdir $CONFDIR
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##FQDN##,$FQDN, \
          -e s,##ROOTURL##,$ROOTURL, \
          -e s,##GITEADB_ROOTPW##,$GITEAADMINPW, \
          -e s,##GITEADB##,$GITEADB, \
          -e s,##GITEADB_USER##,$GITEAUSER, \
          -e s,##GITEADB_PW##,$GITEAUSER_PW, \
	  conf/app.ini-template > $CONFDIR/app.ini
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/gitea-svcs.yaml
      register_module_in_nginx
      ;;

  "init")
      echo "Initiaizing services of ${PREFIX}-${MODULE_NAME}" >&2
      register_module_in_hydra
      SECRET=$(cat $SECRETS_FILE)
      kubectl exec --stdin --tty ${PREFIX}-${MODULE_NAME} -- su git -c "gitea admin auth add-oauth --name ${PREFIX}-${MODULE_NAME} --provider openidConnect --auto-discover-url ${REWRITEPROTO}://$FQDN/hydra/.well-known/openid-configuration --key ${PREFIX}-${MODULE_NAME} --secret $SECRET"
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/gitea-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/gitea-pods.yaml
  ;;

  "uninstall")
      deregister_module_in_nginx
      deregister_module_in_hydra
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/gitea-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

esac

