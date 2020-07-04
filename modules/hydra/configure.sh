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

      CODE_DIR=$MODDATA_DIR/_hydracode_
      _mkdir $CODE_DIR
      if [ -d $CODE_DIR/.git ] ; then
          echo "Code already cloned in folder $CODE_DIR. Pull if necessary" >&2
      else
          echo "Cloning code" >&2
          #git clone https://daevidt@bitbucket.org/daevidt/hydra-consent.git $CODE_DIR
          git clone https://bitbucket.org/daevidt/hydra-consent.git $CODE_DIR
#      [ -d $SRV/_hydracode/consent ] && mv  $SRV/_hydracode/consent $SRV/_hydracode/consent_$(date +"%Y%m%d_%H%M")
      echo "WARN FIXME: Magically put the code into $CODE_DIR/consent" >&2
      fi
      
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

      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HYDRACONSENTDB##/$HYDRACONSENTDB/" \
          -e "s/##HYDRACONSENTDB_USER##/$HYDRACONSENTDB_USER/" \
          -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/" \
          etc/database.php-template > $BUILDMOD_DIR/database.php #FIXME
      cp etc/nginx.conf $BUILDMOD_DIR/ #FIXME
      sed -e "s/##PREFIX##/$PREFIX/"  \
          etc/sites.conf-template > $BUILDMOD_DIR/sites.conf #FIXME
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
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
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
      echo "ITT TARTUNK MOUNT /etc/hydraconfig/"
      exit 3

##          -e "s/##HYDRACONSENTDB##/${HYDRACONSENTDB}/g" \
##          -e "s/##HYDRACONSENTDB_USER##/${HYDRACONSENTDB_USER}/g" \
##          -e "s/##HYDRACONSENTDB_PW##/${HYDRACONSENTDB_PW}/g" \
##          -e "s/##HYDRADB_USER##/${HYDRADB_USER}/g" \
##          -e "s/##HYDRADBROOT_PW##/${HYDRADBROOT_PW}/

      cp build/Dockerfile.hydraconsentdb $RF/
      cp etc/mysql.cnf $RF/

#      cp Dockerfile.hydraconsent-template $RF/Dockerfile.hydraconsent
      #cp -ar src $SRV/_hydracode 
      cp -a hydraconfig/{public-policy.json,consent-app-policy.json,consent-app.json}   $HYDRA_CONFIG/


      ENCFILE=$RF/hydraconsent.enckey
      if [ ! -f $ENCFILE ] ; then
	 hexdump -n 16 -e '"%08X"' /dev/random > $ENCFILE
      fi



# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)
      sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile.keto-template > $RF/Dockerfile.keto

#      sed -e "s/##HYDRACONSENTDB_PW##/$HYDRACONSENTDB_PW/"  Dockerfile.hydraconsent-template > $RF/Dockerfile.hydraconsent
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
	  -e "s/##CONSENT_ENCRYPTIONKEY##/$(cat $ENCFILE)/"  consentconfig/config.php-template > $SRV/_hydracode/consent/application/config/config.php
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##HYDRA_ADMINPW##/$HYDRA_ADMINPW/" \
	  -e "s/##HYDRASYSTEM_SECRET##/$HYDRASYSTEM_SECRET/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
          -e "s/##HYDRACONSENTDB##/${HYDRACONSENTDB}/g" \
          -e "s/##HYDRACONSENTDB_USER##/${HYDRACONSENTDB_USER}/g" \
          -e "s/##HYDRACONSENTDB_PW##/${HYDRACONSENTDB_PW}/g" \
          -e "s/##HYDRADB##/${HYDRADB}/g" \
          -e "s/##HYDRADB_USER##/${HYDRADB_USER}/g" \
          -e "s/##HYDRADB_PW##/${HYDRADB_PW}/g" \
          -e "s/##HYDRADBROOT_PW##/${HYDRADBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE


  	 
      echo "2. Building ${PREFIX}-hydra..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install")
      register_module_in_nginx
      getip_hydra
      cat conf/public-policy.json | \
          curl -u ${HYDRA_API_USER}:${HYDRA_API_PW} ${HYDRA_IP}:5000/api/new-client/${PREFIX}-public -H "Content-Type: application/json" -X POST --data-binary @-
      register_module_in_hydra consent
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hydra-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hydra-pods.yaml

       echo STOP
       exit 3


       echo "Starting containers of ${PREFIX}-hydra"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydra-postgresql
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydraconsent-mysql
#       docker exec ${PREFIX}-hydra-mysql /initdb.sh
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydraconsent
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-hydra
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-keto
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
        sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
            -e "s/##OUTERHOST##/$OUTERHOST/" \
            -e "s/##CONSENTPASSWORD##/$CONSENTAPPPASSWORD/" consentconfig/hydra.php-template > $SRV/_hydracode/consent/application/config/hydra.php

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
      deregister_module_in_nginx
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

