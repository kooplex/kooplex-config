#!/bin/bash

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
        