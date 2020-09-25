#!/bin/bash
MODULE_NAME=seafile
RF=$BUILDDIR/${MODULE_NAME}

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

SEAFILE_CACHE=/kooplex-big/_cache-${PREFIX}-${MODULE_NAME}/
SEAFILE_DATA=$SRV/_${MODULE_NAME}-data
SEAFILE_CONF=$SRV/_${MODULE_NAME}-conf
SEAFILE_DB=$SRV/_${MODULE_NAME}-mysql

case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-${MODULE_NAME}..."

    mkdir -p $SEAFILE_DB $SEAFILE_CACHE  $SEAFILE_DATA/seafile/conf/

    docker $DOCKERARGS volume create -o type=none -o device=$SEAFILE_CACHE -o o=bind ${PREFIX}-cache-${MODULE_NAME}
    docker $DOCKERARGS volume create -o type=none -o device=$SEAFILE_DB -o o=bind ${PREFIX}-${MODULE_NAME}-mysql
    docker $DOCKERARGS volume create -o type=none -o device=$SEAFILE_DATA -o o=bind ${PREFIX}-${MODULE_NAME}-data
    docker $DOCKERARGS volume create -o type=none -o device=$SEAFILE_CONF -o o=bind ${PREFIX}-${MODULE_NAME}-conf


    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" views.py.patch-template > $SEAFILE_DATA/seafile/conf/views.py.patch

    
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##SEAFILEDB_PW##/$SEAFILEDB_PW/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" conf/ccnet.conf-template > $SEAFILE_DATA/seafile/conf/ccnet.conf

    if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
         IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION}
    else
         IMAGE_NAME=${PREFIX}-${MODULE_NAME}
             echo "2. Building ${PREFIX}-${MODULE_NAME}.."
             cp Dockerfile.${MODULE_NAME} Dockerfile.${MODULE_NAME}_pw entrypoint.sh_pw set_password.py $RF/
             docker $DOCKER_HOST build -f $RF/Dockerfile.seafile -t ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}:${IMAGE_REPOSITORY_VERSION} $RF
             docker $DOCKER_HOST build -f $RF/Dockerfile.seafile_pw -t ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-${MODULE_NAME}-pw:${IMAGE_REPOSITORY_VERSION} $RF
             #docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build
    fi

    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
        -e "s/##MODULE_NAME##/${MODULE_NAME}/" \
	-e "s/##SEAFILE_MYSQL_ROOTPW##/$DUMMYPASS/" \
	-e "s/##SEAFILE_ADMIN##/admin@kooplex/" \
        -e "s,##IMAGE_REPOSITORY_URL##,${IMAGE_REPOSITORY_URL},g" \
        -e "s,##IMAGE_REPOSITORY_PREFIX##,${IMAGE_REPOSITORY_PREFIX},g" \
        -e "s,##IMAGE_REPOSITORY_VERSION##,${IMAGE_REPOSITORY_VERSION},g" \
	-e "s/##SEAFILE_ADMINPW##/$DUMMYPASS/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    
 ;;

  "install-hydra")
    register_hydra $MODULE_NAME
    HYDRA_SEAHUBCLIENTID=$PREFIX-seafile
    HYDRA_SEAHUBCLIENTSECRET=`cat $SRV/.secrets/$PREFIX-seafile-hydra.secret`
    sed -e "s/##REWRITEPROTO##/$REWRITEPROTO/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##OUTERHOST##/$OUTERHOST/" \
        -e "s/##SEAFILEDB_PW##/$SEAFILEDB_PW/" \
        -e "s,##URL_HYDRA##,$URL_HYDRA," \
        -e "s/##HYDRA_CLIENTID##/$HYDRA_SEAHUBCLIENTID/" \
	-e "s,##DJANGO_SECRET_KEY##,$DJANGO_SECRET_KEY," \
        -e "s,##HYDRA_CLIENTSECRET##,$HYDRA_SEAHUBCLIENTSECRET," conf/seahub_settings.py-template > $SEAFILE_DATA/seafile/conf/seahub_settings.py
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
#     docker $DOCKERARGS exec ${PREFIX}-${MODULE_NAME} bash -c "$RF/views.py.patch /tmp"
     #RUN patch /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py < /tmp/views.py.patch
     
#     docker $DOCKERARGS exec ${PREFIX}-${MODULE_NAME} bash -c "/shared/seafile/conf/seahub_settings.py"
#     docker $DOCKERARGS exec ${PREFIX}-${MODULE_NAME} bash -c "/shared/seafile/conf/ccnet.conf"
     
     # PATCH FOR THIS VERSION
     docker $DOCKERARGS exec ${PREFIX}-${MODULE_NAME} bash -c "DIR=/opt/seafile/seafile-server-7.0.4/seahub/seahub; sed -i '290c\    return True#' \$DIR/utils/__init__.py &&\
         sed -i \"143c\        user_info['idp_user'] = user_info_json['idp_user']\" \$DIR/oauth/views.py &&\
         sed -i \"167c\    email = user_info['idp_user']\" \$DIR/oauth/views.py &&\
         sed -i '192a\    if isinstance(name, list):\n        name = name.pop(0)' \$DIR/oauth/views.py &&\
         sed -i '198a\    if isinstance(contact_email, list):\n       contact_email = contact_email.pop(0)' \$DIR/oauth/views.py"

  ;;

  "admin")
     echo "Creating Seafile admin user..."
     # https://download.seafile.com/published/seafile-manual/docker/deploy%20seafile%20with%20docker.md
	docker $DOCKERARGS exec -it ${PREFIX}-${MODULE_NAME} /opt/seafile/seafile-server-latest/reset-admin.sh
  ;;

  "stop")
      echo "Stopping container ${PREFIX}-${MODULE_NAME}"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm    

  ;;
  "purge")
    rm -r $RF
     # docker $DOCKERARGS volume rm ${PREFIX}-seafile-data
      docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-data
      docker $DOCKERARGS volume rm ${PREFIX}-${MODULE_NAME}-conf
      docker $DOCKERARGS volume rm ${PREFIX}-seafile-mysql
      docker $DOCKERARGS volume rm ${PREFIX}-cache-seafile
  ;;

  "clean")
    echo "Cleaning data ${PREFIX}-${MODULE_NAME}"
    rm -R -f $SEAFILE_CACHE $SEAFILE_DATA $SEAFILE_DB $SEAFILE_CONF

  ;;


esac
