#!/bin/bash


NEEDS A FIX

<<<<<<< HEAD
case $VERB in   "build")
	echo "Building image kooplex-owncloud-server"
          
        docker $DOCKERARGS build -f Dockerfile-owncloud -t kooplex-owncloud-server .
        ;;
        "install")
        echo "Installing owncloud-server $PROJECT-owncloud-server [$OWNCLOUDIP]"
                          
        # LDAP
        mkdir -p $SRV/owncloud/init
                                                      
        echo "#/bin/sh
        echo \"Configuring LDAP...\"
        chmod 0600 /etc/nslcd.conf
        service nslcd start
        " > $SRV/owncloud/init/0.sh
                                                                    
#        docker $DOCKERARGS create \
#        --name $PROJECT-owncloud-server \
#        --hostname $PROJECT-nemtom \
#        --net $PROJECT-net \
#        --p $OWNCLOUDIP:80 \
#        --privileged \
#        -v $SRV/owncloud/init:/init \
#        owncloud-server

	docker run -it \
		--privileged=true -v \
		/home/jegesm/Owncloud/:/var/www/html/data:rw \
		-v $SRV/owncloud/init:/init   \
		-p 85:80 -p 86:443 \
		--name=owncloud-ldap-wusers kooplex-owncloud-server bash

        ;;
	"start")
	 docker $DOCKERARGS start $PROJECT-owncloud-server
        ;;
        "init")
        ;;
        "stop")
        echo "Stopping owncloud-server $PROJECT-owncloud-server [$OWNCLOUDIP]"
        docker $DOCKERARGS stop $PROJECT-owncloud-server
        ;;
        "remove")
        echo "Removing owncloud-server $PROJECT-owncloud-server [$OWNCLOUDIP]"
        docker $DOCKERARGS rm $PROJECT-notebook
        ;;
        "purge")
        echo "Purging owncloud-server $PROJECT-owncloud-server [$OWNCLOUDIP]"
        rm -R $SRV/owncloud/init
        ;;
        "clean")
        echo "Cleaning base image kooplex-owncloud-server"
        docker $DOCKERARGS rmi kooplex-owncloud-server
        ;;
        esac
        
=======
RF=$BUILDDIR/owncloud
mkdir -p $RF

case $VERB in
  "build")
    mkdir -p $SRV/_owncloud $SRV/_owncloud.mysql $SRV/_owncloud.redis
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_owncloud -o o=bind ${PREFIX}-owncloud
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_owncloud.mysql -o o=bind ${PREFIX}-owncloud-mysql  
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_owncloud.redis -o o=bind ${PREFIX}-owncloud-redis

    echo "Building image ${PREFIX}-owncloud"
    sed -e "s/##DOMAIN##/${OUTERHOST}/" \
        -e "s/##OCADMIN##/ocadmin/" \
        -e "s/##OCADMINPW##/${DUMMYPASS}/" \
        -e "s/##DBROOTPW##/${DUMMYPASS}/" \
        -e "s/##DBUSER##/owncloud/" \
        -e "s/##DBUSERPW##/${DUMMYPASS}/" \
        -e "s/##VOLUMEOC##/${PREFIX}-owncloud/" \
        -e "s/##VOLUMEOCDB##/${PREFIX}-owncloud-mysql/" \
        -e "s/##VOLUMEOCREDIS##/${PREFIX}-owncloud-redis/" \
        -e "s/##NETWORK##/${PREFIX}-net/" \
        -e "s/##NETWORKPRIVATE##/owncloud-net/" \
        -e "s/##CTROC##/${PREFIX}-owncloud/" \
        -e "s/##CTROCDB##/${PREFIX}-owncloud-mysql/" \
        -e "s/##CTROCREDIS##/${PREFIX}-owncloud-redis/" \
        docker-compose.yml-template > $RF/docker-compose.yml
    docker-compose -f $RF/docker-compose.yml build
    sed -e "s/##LDAPORG##/${LDAPORG}/" \
        -e "s/##LDAPIP##/${PREFIX}-ldap/" \
        -e "s/##LDAPPORT##/${LDAPPORT}/" \
        -e "s/##LDAPPW##/${LDAPPW}/" \
        -e "s/##OWNCLOUD##/${PREFIX}-owncloud/" \
        -e "s/##NGINX##/${PREFIX}-nginx/" \
        -e "s/##OUTERHOST##/${OUTERHOST}/" \
        -e "s/##INNERHOST##/${INNERHOST}/" \
        -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
        scripts/setup_ldap.sh-template > $RF/setup_ldap.sh
  ;;

  "install")
  ;;

  "start")
    echo "Starting owncloud ${PREFIX}-owncloud [$OWNCLOUDIP]"
    docker-compose -f $RF/docker-compose.yml up -d
  ;;

  "init")
    echo "Configuring ${PREFIX}-owncloud [$OWNCLOUDIP]"
    docker cp $RF/setup_ldap.sh ${PREFIX}-owncloud:/setup_ldap.sh
    docker exec -t ${PREFIX}-owncloud chmod +x /setup_ldap.sh
    docker exec -t ${PREFIX}-owncloud su www-data -c /setup_ldap.sh
  ;;

  "stop")
    echo "Stopping owncloud $PREFIX-owncloud [$OWNCLOUDIP]"
    docker-compose -f $RF/docker-compose.yml stop
  ;;

  "remove")
    echo "Removing owncloud $PREFIX-owncloud [$OWNCLOUDIP]"
    docker-compose -f $RF/docker-compose.yml rm -f
  ;;

  "purge")
  #  echo "Purging owncloud $PREFIX-owncloud [$OWNCLOUDIP]"
  #  rm -R -f $SRV/ownCloud
    docker $DOCKERARGS volume rm ${PREFIX}-owncloud
    docker $DOCKERARGS volume rm ${PREFIX}-owncloud-mysql  
    docker $DOCKERARGS volume rm ${PREFIX}-owncloud-redis

  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-owncloud"
    rm -R -f $SRV/_owncloud $SRV/_owncloud.mysql $SRV/_owncloud.redis
    
  ;;

  "clean")
  ;;

esac
>>>>>>> origin/devnew
