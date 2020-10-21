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
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##ROOTURL##,$ROOTURL, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  -e s,##GITEA_MYSQL_ROOTPW##,$GITEADB_PW, \
	  -e s,##GITEADB_USER##,$GITEAUSER, \
	  -e s,##GITEADB_PW##,$GITEAUSER_PW, \
          build/gitea-pods.yaml-template > $BUILDMOD_DIR/gitea-pods.yaml

      mkdir_svcdata gitea/gitea/conf
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##FQDN##,$FQDN, \
          -e s,##ROOTURL##,$ROOTURL, \
          -e s,##GITEADB_ROOTPW##,$GITEAADMINPW, \
          -e s,##GITEADB##,$GITEADB, \
          -e s,##GITEADB_USER##,$GITEAUSER, \
          -e s,##GITEADB_PW##,$GITEAUSER_PW, \
	  conf/app.ini-template > $BUILDMOD_DIR/app.ini
       kubectl cp $BUILDMOD_DIR/app.ini helper:/data/gitea/gitea/gitea/conf/app.ini
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/gitea-svcs.yaml
      register_module_in_nginx
      ;;

  "init")
      echo "Initiaizing services of ${PREFIX}-${MODULE_NAME}" >&2
      STATE=$(kubectl get pods | awk "/^$PREFIX-gitea\s/ {print \$3}")
      if [ "$STATE" = "Running" ] ; then
          register_module_in_hydra
          kubectl exec --stdin --tty ${PREFIX}-${MODULE_NAME} -- su git -c "gitea admin auth add-oauth --name ${CLIENT} --provider openidConnect --auto-discover-url ${REWRITEPROTO}://$FQDN/hydra/.well-known/openid-configuration --key ${PREFIX}-${MODULE_NAME} --secret $SECRET"
      else
          echo "Pod for $MODULE_NAME is not running" >&2
      fi
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

