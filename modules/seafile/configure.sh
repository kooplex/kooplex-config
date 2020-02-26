#!/bin/bash
MODULE_NAME=seafile
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

# TODO sed instead of patch
# Ekkor valamiert a conatc_email is az idp_user lesz
# in /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py 
# 143        user_info['idp_user'] = user_info_json['idp_user']
# 168 email = user_info['idp_user']



case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."

    mkdir -p $SRV/_${MODULE_NAME}-mysql
    mkdir -p /kooplex-big/_cache-${MODULE_NAME}/
    mkdir -p $SRV/_${MODULE_NAME}-data

    docker $DOCKERARGS volume create -o type=none -o device=/kooplex-big/_cache-${MODULE_NAME} -o o=bind ${PREFIX}-cache-${MODULE_NAME}
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-mysql -o o=bind ${PREFIX}-${MODULE_NAME}-mysql
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_${MODULE_NAME}-data -o o=bind ${PREFIX}-${MODULE_NAME}-data

    cp Dockerfile.${MODULE_NAME} $RF/
    cp Dockerfile.${MODULE_NAME}_pw $RF/
    cp entrypoint.sh_pw $RF/
    cp set_password.py $RF/

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
	-e "s/##SEAFILE_MYSQL_ROOTPW##/$DUMMYPASS/" \
	-e "s/##SEAFILE_ADMIN##/admin@kooplex/" \
	-e "s/##SEAFILE_ADMINPW##/$DUMMYPASS/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" views.py.patch-template > $RF/views.py.patch

    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
        -e "s/##SEAFILEDB_PW##/$SEAFILEDB_PW/" \
        -e "s,##URL_HYDRA##,$URL_HYDRA," \
        -e "s/##HYDRA_CLIENTID##/$HYDRA_SEAHUBCLIENTID/" \
	-e "s/##DJANGO_SECRET_KEY##/$(echo $DJANGO_SECRET_KEY | sed -e 's/\$/$$/g')/" \
        -e "s/##HYDRA_CLIENTSECRET##/$HYDRA_SEAHUBCLIENTSECRET/" conf/seahub_settings.py-template > $RF/seahub_settings.py
    
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##SEAFILEDB_PW##/$SEAFILEDB_PW/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" conf/ccnet.conf-template > $RF/ccnet.conf


   echo "2. Building ${PREFIX}-${MODULE_NAME}..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 
 ;;

  "install-hydra")
    register_hydra $MODULE_NAME
  ;;
  "uninstall-hydra")
    unregister_hydra $MODULE_NAME
  ;;
  "install-nginx")
    register_nginx $MODULE_NAME
  ;;
  "uninstall-nginx")
    unregister_nginx $MODULE_NAME
  ;;

  "start")
    echo "Starting container ${PREFIX}-${MODULE_NAME}"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d
  ;;

  "init")
  ;;

  "admin")
     echo "Creating Seafile admin user..."
	docker $DOCKERARGS exec -it ${PREFIX}-${MODULE_NAME} /opt/seafile/seafile-server-latest/reset-admin.sh
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
      rm $NGINX_DIR/conf/conf/${MODULE_NAME}
  ;;
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm    

      docker exec  ${PREFIX}-hydra  sh -c "hydra clients  delete ${PREFIX}-${MODULE_NAME}"
      PWFILE=$RF/consent-${MODULE_NAME}.pw
      rm $PWFILE
  ;;

  "cleandata")
    echo "Cleaning data ${PREFIX}-${MODULE_NAME}"
    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
    rm -R -f $SRV/_${MODULE_NAME}-data  
  ;;

  "purge")
###    echo "Removing $RF" 
###    rm -R -f $RF
###    docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
  ;;

esac
