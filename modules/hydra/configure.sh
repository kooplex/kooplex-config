#!/bin/bash


DOCKER_HOST=$DOCKERARGS

# After consent install
# /consent/install and click the button
# sed 'files'; #### --> 'database'; ####
#


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svcconf
      mkdir_svclog
      mkdir_svcdata

      mkdir_svcdata _hydracode_
      HELPER_CODE_DIR=/data/hydra/_hydracode_
      kubectl exec -it helper -- bash -c "[ -d $HELPER_CODE_DIR/.git ] || git clone https://github.com/kooplex/hydra-consent.git $HELPER_CODE_DIR"

      echo "Patching and configuring code" >&2
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##HYDRACONSENTDB##,$HYDRACONSENTDB, \
          -e s,##HYDRACONSENTDB_USER##,$HYDRACONSENTDB_USER, \
          -e s,##HYDRACONSENTDB_PW##,$HYDRACONSENTDB_PW, \
          conf/database.php-template > $BUILDMOD_DIR/database.php
      kubectl cp $BUILDMOD_DIR/database.php helper:$HELPER_CODE_DIR/application/config/database.php

      ENCFILE=$BUILDMOD_DIR/hydraconsent.enckey
      if [ ! -f $ENCFILE ] ; then
         hexdump -n 16 -e '"%08X"' /dev/random > $ENCFILE
         echo "Created encryption $ENCFILE" >&2
      fi
      sed -e s,##PREFIX##,${PREFIX}, \
          -e s,##REWRITEPROTO##,${REWRITEPROTO}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##CONSENT_ENCRYPTIONKEY##,"$(cat $ENCFILE)", \
          conf/config.php-template > $BUILDMOD_DIR/config.php
      kubectl cp $BUILDMOD_DIR/config.php-template helper:$HELPER_CODE_DIR/application/config/config.php

      create_rootCA
      cp -a $CA_DIR/rootCA.{key,crt} $BUILDMOD_DIR

      cp scripts/hydra-entrypoint.sh $BUILDMOD_DIR
      cp scripts/api.py $BUILDMOD_DIR
      cp scripts/02-api-start.sh $BUILDMOD_DIR
      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##HYDRA_ADMINPW##,$HYDRA_ADMINPW, \
          conf/hydra.yml-template > $BUILDMOD_DIR/hydra.yml
      sed -e s,##PREFIX##,${PREFIX}, \
          build/Dockerfile.hydra-template > $BUILDMOD_DIR/Dockerfile.hydra
      docker $DOCKERARGS build -t ${PREFIX}-hydra -f $BUILDMOD_DIR/Dockerfile.hydra $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-hydra ${MY_REGISTRY}/${PREFIX}-hydra
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-hydra

      mkdir_svcconf consent-nginx
      sed -e "s/##PREFIX##/$PREFIX/"  \
          conf/sites.conf-template > $BUILDMOD_DIR/consent-nginx-default
      kubectl cp $BUILDMOD_DIR/consent-nginx-default helper:/conf/hydra/consent-nginx/default

      cp scripts/hydraconsent-entrypoint.sh $BUILDMOD_DIR
      sed -e s,##PREFIX##,${PREFIX}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##MAIL_SERVER_HOSTNAME##,$MAIL_SERVER_HOSTNAME, \
	  build/Dockerfile.hydraconsent-template > $BUILDMOD_DIR/Dockerfile.hydraconsent

      docker $DOCKERARGS build -t ${PREFIX}-hydraconsent -f $BUILDMOD_DIR/Dockerfile.hydraconsent $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-hydraconsent ${MY_REGISTRY}/${PREFIX}-hydraconsent
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-hydraconsent

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/hydra-svcs.yaml-template > $BUILDMOD_DIR/hydra-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
          -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s,##HYDRADB##,${HYDRADB},g \
          -e s,##HYDRA_POSTGRESQL_USER##,postgres,g \
          -e s,##HYDRA_POSTGRESQL_PW##,"${HYDRA_POSTGRESQL_PW}",g \
          -e s,##HYDRACONSENT_MYSQL_ROOTPW##,"${HYDRACONSENT_MYSQL_ROOTPW}",g \
          -e s,##HYDRACONSENTDB##,"${HYDRACONSENTDB}",g \
          -e s,##HYDRACONSENTDB_PW##,"${HYDRACONSENTDB_PW}",g \
          -e s,##HYDRACONSENTDB_USER##,"${HYDRACONSENTDB_USER}",g \
	  -e s,##HYDRASYSTEM_SECRET##,"$HYDRASYSTEM_SECRET", \
          -e s,##HYDRA_ADMINPW##,$HYDRA_ADMINPW, \
          -e s,##HYDRA_API_USER##,$HYDRA_API_USER, \
          -e s,##HYDRA_API_PW##,$HYDRA_API_PW, \
	  build/hydra-pods.yaml-template > $BUILDMOD_DIR/hydra-pods.yaml
  ;;

  "install")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hydra-svcs.yaml
      register_module_in_nginx
      getip_hydra
      echo "Register public policy" >&2
      sed -e s,##PREFIX##,$PREFIX, conf/public-policy.json | \
          curl -u ${HYDRA_API_USER}:${HYDRA_API_PW} ${HYDRA_IP}:5000/api/new-policy/${PREFIX}-public -H "Content-Type: application/json" -X POST --data-binary @-

      register_module_in_hydra consent
      sed -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s,##FQDN##,$FQDN, \
          -e s,##PREFIX##,$PREFIX, \
          -e s,##CONSENTPASSWORD##,$SECRET, \
          conf/hydra.php-template > $BUILDMOD_DIR/hydra_patched.php
      kubectl cp $BUILDMOD_DIR/hydra_patched.php helper:/data/hydra/_hydracode_/application/config/hydra.php
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hydra-pods.yaml
  ;;

  "init")
      echo "UNDONE"
      exit 3
  

	echo "I need to sleep for 10 secs"
	sleep 10

	docker exec  ${PREFIX}-hydra  sh -c "hydra policies create -f /etc/hydraconfig/public-policy.json"
	docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/client-hub.json"
	PWFILE=$RF/consent-app.pw
	if [ ! -f $PWFILE ] ; then
		docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/consent-app.json > /consent-app.pw" && \
			docker cp  ${PREFIX}-hydra:/consent-app.pw $PWFILE
	fi
	CONSENTAPPPASSWORD=$(cut -f4 -d\  $PWFILE | cut -d: -f2)

#	hydra 0.x esetén:
	docker exec  ${PREFIX}-hydra  sh -c "hydra policies import /etc/hydraconfig/consent-app-policy.json"
	docker exec  ${PREFIX}-hydra  sh -c "hydra policies import /etc/hydraconfig/client-policy-hub.json"

#	hydra 1.x esetén:
#	docker exec  ${PREFIX}-hydra  sh -c "hydra policies create -f /etc/hydraconfig/consent-app-policy.json"
#	docker exec  ${PREFIX}-hydra  sh -c "hydra policies create -f /etc/hydraconfig/client-policy-hub.json"

## This might give an error first. It might be that first we need to load the site first in browser
	docker exec ${PREFIX}-hydraconsent-mysql mysql --password=$HYDRACONSENTDB_PW $HYDRACONSENTDB -e  "update bf_settings set value = 'noreply@elte.hu' where name = 'sender_email';"

#\c monitor
#GRANT readaccess TO usage_viewer;
#ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON DATABASE $HYDRADB TO $HYDRADB_USER;
#GRANT USAGE ON SCHEMA public to usage_viewer;
#GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO usage_viewer;
#GRANT SELECT ON ALL TABLES IN SCHEMA public TO usage_viewer;



  ;;

  "refresh")
  ;;

  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hydra-pods.yaml
  ;;

  "uninstall")
   #   deregister_module_in_nginx
      getip_hydra
      curl -X DELETE -u ${HYDRA_API_USER}:${HYDRA_API_PW} ${HYDRA_IP}:5000/api/remove/${PREFIX}-public
      deregister_module_in_hydra consent
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hydra-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;
esac

