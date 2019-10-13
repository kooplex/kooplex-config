#!/bin/bash

RF=$BUILDDIR/slurm

mkdir -p $RF
mkdir -p $RF/$NOTEBOOK_DOCKER_EXTRA

DOCKER_HOST=$DOCKERARGS
DOCKER_COMPOSE_FILE=$RF/docker-compose.yml

# TODO
# 1. /etc/hosts in slurmctld has to have the fqdn of compute nodes or something else
# 2. insert partition info into slurm.conf
#
# install mailx and sendmail and setup
# vim /etc/mail.rc
#     set smtp=smtp://smtp.gmail.com:587
#     set smtp-auth=login
#     set smtp-auth-user=kooplex.ena@gmail.com
#     set smtp-auth-password=appletree137
#     set ssl-verify=ignore
#     set smtp-use-starttls
#     set nss-config-dir=/etc/pki/nssdb/
#
# and 'scontrol reconfigure'
#
# munge.key needs to be generated from somewhere
#

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-slurm..."
      
      mkdir -p $SRV/_slurm_mysql $SRV/_slurm_etc $SRV/_slurm_etc/munge $SRV/_slurm_etc/slurm $SRV/_slurm_etc/data \
         $SRV/_slurm_etc/var_log_slurm   

      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_slurm_etc/munge -o o=bind ${PREFIX}-etc-munge
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_slurm_etc/slurm -o o=bind ${PREFIX}-etc-slurm
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_slurm_etc/data -o o=bind ${PREFIX}-slurm-jobdir
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_slurm_mysql -o o=bind ${PREFIX}-slurmdb
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_slurm_etc/var_log_slurm -o o=bind ${PREFIX}-var-log-slurm


      cp Dockerfile $RF/
      cp etc/docker-entrypoint.sh $RF/
#      sed -e "s/##PREFIX##/$PREFIX/" \
#          -e "s/##HUBDB##/${HUBDB}/g" \
#          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
#          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
#          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" scripts/runserver.sh > $RF/runserver.sh
      sed -e "s/##PREFIX##/$PREFIX/" etc/slurm.conf-template > $SRV/_slurm_etc/slurm/slurm.conf
      sed -e "s/##PREFIX##/$PREFIX/" etc/slurmdbd.conf-template > $SRV/_slurm_etc/slurm/slurmdbd.conf

      # Create key for munge
      dd if=/dev/urandom bs=1 count=1024 > $SRV/_slurm_etc/munge/munge.key
      sed -e "s/##PREFIX##/$PREFIX/" \
          -e "s/##PROXYTOKEN##/$PROXYTOKEN/" \
          -e "s/##HUBDB_USER##/${HUBDB_USER}/g" \
          -e "s/##HUB_USER##/${HUB_USER}/g" \
          -e "s/##HUBDB_PW##/${HUBDB_PW}/g" \
          -e "s/##HUBDBROOT_PW##/${HUBDBROOT_PW}/" docker-compose.yml-template > $DOCKER_COMPOSE_FILE
  	 
      echo "2. Building ${PREFIX}-slurm..."
      docker-compose $DOCKER_HOST -f $DOCKER_COMPOSE_FILE build


      #TODO need munge.key and slurm.conf in notebook containers and compute nodes too
      cp $SRV/_slurm_etc/slurm/slurm.conf $SRV/_slurm_etc/munge/munge.key etc/slurm-Docker-piece $RF/$NOTEBOOK_DOCKER_EXTRA/
  ;;

  "install")
  ;;

  "start")
       echo "Starting containers of ${PREFIX}-slurm"
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-slurmdb
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-slurmdbd
#       docker exec ${PREFIX}-slurm-mysql /initdb.sh
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-slurmctld
       docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE up -d ${PREFIX}-c1
  ;;

  "init")
  ;;


  "stop")
      echo "Stopping containers of ${PREFIX}-slurm"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE down
  ;;

  "remove")
      echo "Removing containers of ${PREFIX}-slurm"
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE kill
      docker-compose $DOCKERARGS -f $DOCKER_COMPOSE_FILE rm
  ;;

  "purge")
      echo "Removing $RF" 
      rm -R -f $RF
      
      docker $DOCKERARGS volume rm ${PREFIX}-home
      docker $DOCKERARGS volume rm ${PREFIX}-course
      docker $DOCKERARGS volume rm ${PREFIX}-usercourse
      docker $DOCKERARGS volume rm ${PREFIX}-share
      docker $DOCKERARGS volume rm ${PREFIX}-slurmdb
      docker $DOCKERARGS volume rm ${PREFIX}-garbage
  ;;
  "cleandata")
    echo "Cleaning data ${PREFIX}-slurmdb"
    rm -R -f $SRV/mysql
    
  ;;

  "clean")
  ;;

esac

