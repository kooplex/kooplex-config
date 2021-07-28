#!/bin/bash



# TODO
#
# COMPUTE NODES
# 1. /etc/hosts in slurmctld has to have the fqdn of compute nodes or something else
# 2. insert partition info into slurm.conf
# 3. we need a way to easily setup new compute nodes
#   a, storages need to be mounted 
#   b, need to acces the same user database LDAP:
# install nslcd into compute node image
# cp /etc/mnt/nslcd.conf /etc/nslcd.conf
# nslcd #start
# !!! might need to restart munge
#
# 4, For accounting and access restrictions Slurm needs to access the same user database ( extend kooplex oauth! )
#
# MAILING
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
# INTERNAL authentication
# munge.key needs to be generated from somewhere
#
# INTO Userspace
# RUN apt install -y slurm-client
# #RUN sed -i -e "s/bionic/xenial/g" /etc/apt/sources.list && apt update && apt install -y slurm-client
# #RUN sed -i -e "s/xenial/bionic/g" /etc/apt/sources.list && apt update
# ADD slurm.conf /etc/slurm-llnl/
# ADD munge.key /etc/munge/munge.key
#
# TROUBLESHOOTING
# if node is down
# check whether munge.key was changed or not: service munge restart
# scontrol update nodename=node001 state=resume
#

case $VERB in
  "build")
      echo "1. Configuring ${PREFIX}-${MODULE_NAME}..." >&2
      mkdir_svclog
      mkdir_svcdata
      mkdir_svcconf

      mkdir_svcdata mysql 
      mkdir_svcconf etc
      mkdir_svcconf munge 

#      kubectl create namespace $NS_HUB || true
      kubectl create namespace slurm || true

      #TODO need munge.key and slurm.conf in notebook containers and compute nodes too
#      cp $SRV/_slurm_etc/slurm/slurm.conf $SRV/_slurm_etc/munge/munge.key etc/slurm-Docker-piece $RF/$NOTEBOOK_DOCKER_EXTRA/

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
	  build/${MODULE_NAME}-pods.yaml-template > $BUILDMOD_DIR/${MODULE_NAME}-pods.yaml

      cp Dockerfile $BUILDMOD_DIR/
      docker build $DOCKER_HOST -f $BUILDMOD_DIR/Dockerfile -t ${PREFIX}-${MODULE_NAME} .
      docker $DOCKERARGS tag ${PREFIX}-${MODULE_NAME} ${MY_REGISTRY}/${PREFIX}-${MODULE_NAME}
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-${MODULE_NAME}

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          -e s,##SERVICENODE##,${SERVICE_NODE}, \
          -e s,##MY_REGISTRY##,$MY_REGISTRY, \
	  build/cns-pods.yaml-template > $BUILDMOD_DIR/cns-pods.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/${MODULE_NAME}-svcs.yaml-template > $BUILDMOD_DIR/${MODULE_NAME}-svcs.yaml

      sed -e s,##PREFIX##,$PREFIX, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
	  build/cns-svcs.yaml-template > $BUILDMOD_DIR/cns-svcs.yaml
  ;;

  "install")
      echo "Install services of ${PREFIX}-${MODULE_NAME}" >&2


      # Create key for munge
#      MUNGE_SECRET=`dd if=/dev/urandom bs=1 count=1024 > $BUILDMOD_DIR/munge.key`
	cp etc/munge.key $BUILDMOD_DIR/

      kubectl apply -f $BUILDMOD_DIR/${MODULE_NAME}-svcs.yaml || true
      echo "Store slurm config files in configmap" >&2

      sed -e s,##FQDN##,$FQDN, \
          -e s,##PREFIX##,$PREFIX, \
	  -e s,##NS##,$NS_SLURM, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          etc/slurm.conf-template   \
              > $BUILDMOD_DIR/slurm.conf

      sed -e s,##FQDN##,$FQDN, \
          -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_SLURM, \
          -e s,##MODULE_NAME##,$MODULE_NAME, \
          etc/slurmdbd.conf-template   \
              > $BUILDMOD_DIR/slurmdbd.conf

      sed -e s,##FQDN##,$FQDN, \
          -e s,##PREFIX##,$PREFIX, \
          -e s,##NS##,$NS_SLURM, \
          etc/mailrc-template   \
              > $BUILDMOD_DIR/mail.rc

       kubectl create configmap $PREFIX-${MODULE_NAME} \
	       --from-file=slurm=$BUILDMOD_DIR/slurm.conf \
	       --from-file=slurmdbd=$BUILDMOD_DIR/slurmdbd.conf \
	       --from-file=munge=$BUILDMOD_DIR/munge.key \
	       --from-file=mailrc=$BUILDMOD_DIR/mail.rc \
	       -o yaml --dry-run=client | kubectl replace -f - #--validate=false  
	       #-o yaml -n $NS_SLURM --dry-run=client | kubectl replace -f - #--validate=false  
  ;;

  "start")
      echo "Starting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl apply -f $BUILDMOD_DIR/${MODULE_NAME}-pods.yaml
  ;;

  "stop")
      echo "Deleting pods of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/${MODULE_NAME}-pods.yaml
  ;;

  "uninstall")
      echo "Deleting services of ${PREFIX}-${MODULE_NAME}" >&2
      kubectl delete -f $BUILDMOD_DIR/${MODULE_NAME}-svcs.yaml || true
      kubectl delete configmap $PREFIX-${MODULE_NAME}
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;

  "purge")
      purgedir_svc
  ;;

esac

