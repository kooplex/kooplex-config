#!/bin/bash


case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svclog
      mkdir_svcdata
      
      CODE_DIR=$MODDATA_DIR/_hubcode_
      _mkdir $CODE_DIR
      if [ -d $CODE_DIR/.git ] ; then
          echo "Code already cloned in folder $CODE_DIR. Pull if necessary"
      else
          git clone https://github.com/kooplex/kooplex-hub.git $CODE_DIR
      fi

      sed -e s,##PREFIX##,${PREFIX}, \
          build/Dockerfile.hub-template > $BUILDMOD_DIR/Dockerfile.hub

      cp scripts/runserver.sh $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-hub -f $BUILDMOD_DIR/Dockerfile.hub $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-hub localhost:5000/${PREFIX}-hub
      docker push localhost:5000/${PREFIX}-hub

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/hub-svcs.yaml-template > $BUILDMOD_DIR/hub-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##KUBE_MASTERNODE##,${KUBE_MASTERNODE}, \
          -e s,##FQDN##,$FQDN, \
          -e s,##DJANGO_SECRET_KEY##,$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g'), \
          -e s,##HUB_MYSQL_ROOTPW##,$HUBDB_PW, \
	  build/hub-pods.yaml-template > $BUILDMOD_DIR/hub-pods.yaml


      echo "NOT REACHED THE END"
      exit 3

#      cp $BUILDDIR/CA/rootCA.crt $RF/

# Ez a config.sh-ban van      LDAPPW=$(getsecret ldap)
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" scripts/runserver.sh > $RF/runserver.sh
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##HUBDB##/${HUBDB}/g" \
          -e "s/##OUTERHOST##/$OUTERHOST/" \
          -e "s/##OUTERPORT##/$OUTERHOSTPORT/" \
          -e "s/##INNERHOST##/$INNERHOST/" \
          -e "s/##INNERHOSTNAME##/$INNERHOSTNAME/" \
          -e "s/##DBHOST##/${PREFIX}-hub-mysql/" \
          -e "s/##PROTOCOL##/$REWRITEPROTO/" \
          -e "s/##LDAPBASEDN##/$LDAPORG/" \
          -e "s/##LDAPUSER##/admin/" \
          -e "s/##LDAPBIND_PW##/$HUBLDAP_PW/" \
          -e "s/##HUBLDAP_PW##/$HUBLDAP_PW/" \
          -e "s/##MINUID##/$MINUID/" \
          -e "s/##DOCKERHOST##/$(echo $DOCKERIP | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERAPIURL##/$(echo $DOCKERAPIURL | sed s"/\//\\\\\//"g)/" \
          -e "s/##DOCKERPORT##/$DOCKERPORT/" \
          -e "s/##DOCKERPROTOCOL##/$DOCKERPROTOCOL/" \
          -e "s/##DOCKER_VOLUME_DIR##/$(echo $DOCKER_VOLUME_DIR | sed s"/\//\\\\\//"g)/" \
          -e "s/##IPPOOLLO##/$IPPOOLB/" \
          -e "s/##IPPOOLHI##/$IPPOOLE/" \
          -e "s/##HYDRA_OIDC_SECRET_HUB##/${HYDRA_OIDC_SECRET_HUB}/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" \
          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
          -e "s/##HUB_USER##/${HUB_USER}/g" \
          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
  	 
#For hydra
      sed -e "s/##PREFIX##/${PREFIX}/" hydraconfig/client-policy-hub.json-template > $HYDRA_CONFIG/client-policy-hub.json
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" hydraconfig/client-hub.json-template > $HYDRA_CONFIG/client-hub.json

      echo "2. Building ${PREFIX}-hub..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
  ;;

  "install")

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s,##FQDN##,$FQDN, \
          conf/nginx-${MODULE_NAME}-template > $SERVICECONF_DIR/nginx/conf.d/sites-enabled/${MODULE_NAME}
      restart_nginx

      echo NOT REACHED END
      exit 3

      sed -e "s/##PREFIX##/$PREFIX/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" outer-nginx-hub-template > $CONF_DIR/outer_nginx/sites-enabled/hub

#For hydra
      sed -e "s/##PREFIX##/${PREFIX}/" hydraconfig/client-policy-${MODULE_NAME}.json-template > $HYDRA_CONFIG/client-policy-${MODULE_NAME}.json
      sed -e "s/##PREFIX##/${PREFIX}/" \
	  -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
	  -e "s/##OUTERHOST##/${OUTERHOST}/" hydraconfig/client-${MODULE_NAME}.json-template > $HYDRA_CONFIG/client-${MODULE_NAME}.json

      PWFILE=$RF/consent-${MODULE_NAME}.pw
      if [ ! -f $PWFILE ] ; then
  	  docker exec  ${PREFIX}-hydra  sh -c "hydra clients  import /etc/hydraconfig/consent-${MODULE_NAME}.json > /consent-${MODULE_NAME}.pw" && \
          docker cp  ${PREFIX}-hydra:/consent-${MODULE_NAME}.pw $PWFILE
      fi
      CONSENTAPPPASSWORD=$(cut -f4 -d\  $PWFILE | cut -d: -f2)

      docker $DOCKERARGS exec ${PREFIX}-hydra sh -c 'hydra policies import /etc/hydraconfig/client-policy-${MODULE_NAME}.json'
  ;;

  "start")
      echo "Starting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hub-svcs.yaml
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/hub-pods.yaml
  ;;


  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hub-pods.yaml
  ;;

  "remove")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/hub-svcs.yaml
  ;;

  "purge")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
      purgedir_svc
  ;;

 #### "init")
#####       docker exec ${PREFIX}-hub-mysql /initdb.sh
 ####      #docker exec ${PREFIX}-hub-mysql bash -c "echo 'show databases' | mysql -u root --password=$HUBDBROOT_PW -h $PREFIX-hub-mysql  | grep  -q $HUBDB"
#####       docker exec ${PREFIX}-hub-mysql bash -c "echo 'use $HUBDB' | mysql -u root --password=$HUBDBROOT_PW -h $PREFIX-hub-mysql"
#####       if [ ! $? -eq 0 ];then
 ####         docker exec ${PREFIX}-hub-mysql bash -c " echo \"CREATE DATABASE $HUBDB; CREATE USER '$HUBDB_USER'@'%' IDENTIFIED BY '$HUBDB_PW'; GRANT ALL ON $HUBDB.* TO '$HUBDB_USER'@'%';\" |  \
 ####           mysql -u root --password=$HUBDBROOT_PW  -h $PREFIX-hub-mysql"
#####       fi
 ####      docker exec ${PREFIX}-hub-mysql bash -c "echo 'use $HUBDB' | mysql -u root --password=$HUBDBROOT_PW -h $PREFIX-hub-mysql"
 ####      docker exec ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py makemigrations
 ####      docker exec ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py migrate
 ####      docker exec -it ${PREFIX}-hub python3 /kooplexhub/kooplexhub/manage.py createsuperuser
 #### ;;

 #### "refresh")
 ####    #FIXME: docker $DOCKERARGS exec $PREFIX-hub bash -c "cd /kooplexhub; git pull;"
 #### ;;

 #### "stop")
 ####     echo "Stopping containers of ${PREFIX}-hub"
 ####     docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
 ####     rm  $NGINX_DIR/conf/conf/hub
 #### ;;

 #### "remove")
 ####     echo "Removing containers of ${PREFIX}-hub"
 ####     docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
 ####     docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm

 ####     docker exec  ${PREFIX}-hydra  sh -c "hydra clients  delete ${PREFIX}-${MODULE_NAME}"
 ####     PWFILE=$RF/consent-${MODULE_NAME}.pw
 ####     rm $PWFILE
 #### ;;

 #### "purge")
 ####     echo "Removing $RF" 
 ####     rm -R -f $RF
 ####     
 ####     docker $DOCKERARGS volume rm ${PREFIX}-home
 ####     docker $DOCKERARGS volume rm ${PREFIX}-course
 ####     docker $DOCKERARGS volume rm ${PREFIX}-usercourse
 ####     docker $DOCKERARGS volume rm ${PREFIX}-share
 ####     docker $DOCKERARGS volume rm ${PREFIX}-hubdb
 ####     docker $DOCKERARGS volume rm ${PREFIX}-garbage
 #### ;;
 #### "cleandata")
 ####   echo "Cleaning data ${PREFIX}-hubdb"
 ####   rm -R -f $SRV/mysql
 ####   
 #### ;;

 #### "clean")
####  ;;

esac

