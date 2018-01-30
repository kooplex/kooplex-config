#!/bin/bash

RF=$BUILDDIR/gitlab

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml


case $VERB in
  "build")
    echo "1. Configuring ${PREFIX}-gitlab..."

    mkdir -p $SRV/_gitlabdb
    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_gitlabdb -o o=bind ${PREFIX}-gitlabdb
#    docker $DOCKERARGS volume create -o type=none -o device=$SRV/_git -o o=bind ${PREFIX}-git

    # Generate Gitlab and keyfile random password
    GITLABPASS=$(createsecret gitlab)
    SSHKEYPASS=$(createsecret sshkey)
  
    GITLABNET=${PREFIX}-gitlab-privatenet
  
    cp Dockerfile.gitlab Dockerfile.gitlabdb $RF
    cp scripts/docker-entrypoint.sh $RF    
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##GITLABDBPW##/$GITLABDBPW/" \
        -e "s/##GITLABNET##/$GITLABNET/" \
        -e "s/##PROXYTOKEN##/$PROXYTOKEN/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
    sed -e "s/##HOST##/$OUTERHOST/" etc/nginx-gitlab-http.conf.erb > $RF/nginx-gitlab-http.conf.erb
    
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##LDAPORG##/$LDAPORG/" \
        -e "s/##LDAPPW##/$LDAPPW/" \
        -e "s/##LDAPPORT##/${LDAPPORT}/" \
        -e "s/##LDAPBINDROOTPW##/$DUMMYPASS/"  \
        -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
        -e "s/##OUTERHOST##/${OUTERHOST}/" \
        -e "s/##EMAIL##/${EMAIL}/" \
        -e "s/##SMTP##/${SMTP}/" \
        -e "s/##GITLABDB##/${PREFIX}-gitlabdb/" \
        -e "s/##GITLABDBPW##/${GITLABDBPW}/" etc/gitlab.rb > $RF/gitlab.rb
    sed -e "s/##LDAPORG##/$LDAPORG/" \
        -e "s/##LDAPPW##/$LDAPPW/" \
        -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##INNERHOST##/$INNERHOST/" \
        -e "s/##GITLABADMIN##/${GITLABADMIN}/" \
        -e "s/##GITLABADMINPW##/${GITLABADMINPW}/" scripts/make_admin.sh-template > $RF/make_admin.sh
   echo "2. Building ${PREFIX}-gitlab..."
   docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build 

 ;;
  "install")
    echo "Installing gitlab $PREFIX-gitlab [$GITLABIP]"

  ;;
  "start")
    echo "Starting container ${PREFIX}-gitlab"
    docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d


  ;;
  "init")
    docker $DOCKERARGS exec --user postgres $PREFIX-gitlabdb bash -c 'createdb gitlabhq_production'

   
#    chmod 600 $SRV/gitlab/etc/ssh_host_*
  ;;
  "admin")
     echo "Creating Gitlab admin user..."
     docker $DOCKERARGS exec ${PREFIX}-impersonator bash -c /create_admin.sh 
     sleep 2 
     docker $DOCKERARGS exec ${PREFIX}-gitlab bash -c /make_admin.sh
     echo "MAKE SURE THAT GITLABADMIN IS ADMIN!!!!"
  ;;
  "stop")
      echo "Stopping container ${PREFIX}-gitlab"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;
    
  "remove")
      echo "Removing $DOCKER_COMPOSE_FILE"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
      
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-gitlab"
    docker $DOCKERARGS volume rm ${PREFIX}-gitlabdb
    rm -R -f $SRV/_gitlabdb
    
  ;;

  "purge")
    echo "Removing $RF" 
    rm -R -f $RF
    docker $DOCKERARGS volume rm ${PREFIX}-gitlabdb
  ;;
esac
