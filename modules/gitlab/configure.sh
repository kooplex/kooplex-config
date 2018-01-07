#!/bin/bash

RF=$BUILDDIR/gitlab

mkdir -p $RF

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

    LDAPPASS=$(getsecret ldap)

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
    GITLABSUBNET=172.19.0.0
    GITLABDBIP=172.19.0.2
  
    cp Dockerfile.gitlab $RF
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##GITLABDBPW##/$GITLABDBPW/" \
        -e "s/##GITLABDBIP##/$GITLABDBIP/" \
        -e "s/##GITLABNET##/$GITLABNET/" \
        -e "s/##GITLABSUBNET##/$GITLABSUBNET/" \
        -e "s/##PROXYTOKEN##/$PROXYTOKEN/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE

    sed -e "s/##HOST##/$OUTERHOSTNAME/" etc/nginx-gitlab-http.conf.erb > $RF/nginx-gitlab-http.conf.erb
    
    sed -e "s/##PREFIX##/$PREFIX/" \
        -e "s/##LDAPORG##/$LDAPORG/" \
        -e "s/##LDAPPW##/$LDAPPASS/" \
        -e "s/##LDAPBINDROOTPW##/$DUMMYPASS/"  \
        -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
        -e "s/##OUTERHOST##/${OUTERHOST}/" \
        -e "s/##EMAIL##/${EMAIL}/" \
        -e "s/##SMTP##/${SMTP}/" \
        -e "s/##GITLABDB##/${GITLABDBIP}/" \
        -e "s/##GITLABDBPW##/${GITLABDBPW}/" etc/gitlab.rb > $RF/gitlab.rb

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

    echo "Creating Gitlab admin user..."
    echo "MAKE SURE THAT GITLABADMIN IS ADMIN!!!!"
    echo "Securing host keys..."
#    chmod 600 $SRV/gitlab/etc/ssh_host_*
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

  "purge")
    echo "Removing $RF" 
    rm -R -f $RF
  ;;
esac
