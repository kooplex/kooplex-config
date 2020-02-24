#!/bin/bash

RF=$BUILDDIR/userdb

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-userdb..."

    mkdir -p $SRV/_userdb
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_userdb -o o=bind ${PREFIX}-userdb

    cp Dockerfile.userdb $RF/
    # Generate Userdb-postgres random password
    USERDBPASS=$(createsecret userdb)
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##GITLABDBPW##/$USERDBPW/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    
   
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 

 ;;
  "install")
    echo "Installing userdb $PREFIX-userdb "

  ;;
  "start")
    echo "Starting container ${PREFIX}-userdb"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d


  ;;
  "init")
    docker $DOCKERARGS exec --user postgres $PREFIX-userdb bash -c 'createdb '

   
#    chmod 600 $SRV/userdb/etc/ssh_host_*
  ;;
  "admin")
     echo "Creating Gitlab admin user..."
     docker $DOCKERARGS exec ${PREFIX}-impersonator bash -c /create_admin.sh 
     sleep 2 
     docker $DOCKERARGS exec ${PREFIX}-userdb bash -c /make_admin.sh
     echo "MAKE SURE THAT GITLABADMIN IS ADMIN!!!!"
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-userdb"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
      
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-userdb"
    docker $DOCKERARGS volume rm ${PREFIX}-userdb
    rm -R -f $SRV/_userdb
    
  ;;

  "purge")
    echo "Removing $RF" 
    rm -R -f $RF
    docker $DOCKERARGS volume rm ${PREFIX}-userdb
  ;;
esac
