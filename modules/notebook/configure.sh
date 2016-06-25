#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-notebook"
    
    docker $DOCKERARGS build -t kooplex-notebook .
  ;;
  "install")
    echo "Installing notebook $PROJECT-notebook [$NOTEBOOKIP]"
    
    mkdir -p $SRV/notebook/etc
    mkdir -p $SRV/notebook/etc/ldap
    printf "$(ldap_ldapconfig)\n\n" > $SRV/notebook/etc/ldap/ldap.conf
    printf "$(ldap_nsswitchconfig)\n\n" > $SRV/notebook/etc/nsswitch.conf
    printf "$(ldap_nslcdconfig)\n\n" > $SRV/notebook/etc/nslcd.conf
    chown root $SRV/notebook/etc/nslcd.conf
    chmod 0600 $SRV/notebook/etc/nslcd.conf
    
    mkdir -p $SRV/notebook/init
    # NFS mount for home
    echo "#/bin/sh
echo \"Mounting home...\"
mount -t nfs $PROJECT-home:/exports/home /home" \
      > $SRV/notebook/init/0.sh
    # Start jupyter
    echo "#/bin/sh
echo \"Starting notebook for \$NB_USER...\"
cd /home/\$NB_USER
. start-notebook.sh --NotebookApp.base_url=\$NB_URL --NotebookApp.port=\$NB_PORT " \
      > $SRV/notebook/init/1.sh
    
    # TODO: we create a notebook container here for testing but
    # individual containers will later be created for single
    # users
    docker $DOCKERARGS create \
      --name $PROJECT-notebook \
      --hostname $PROJECT-notebook \
      --net $PROJECT-net \
      --ip $NOTEBOOKIP \
      --privileged \
      -v $SRV/notebook/etc/ldap/ldap.conf:/etc/ldap.conf \
      -v $SRV/notebook/etc/nslcd.conf:/etc/nslcd.conf \
      -v $SRV/notebook/etc/nsswitch.conf:/etc/nsswitch.conf \
      -v $SRV/notebook/init:/init \
      -e NB_USER=test \
      -e NB_UID=10002 \
      -e NB_GID=10002 \
      -e NB_URL=/notebook/test/ \
      -e NB_PORT=8888 \
      kooplex-notebook
  ;;
  "start")
    # TODO: we have a single notebook server now, perhaps there will
    # one per user later or more if we scale out
    # echo "Starting notebook $PROJECT-notebook [$NOTEBOOKIP]"
    # docker $DOCKERARGS start $PROJECT-notebook
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping notebook $PROJECT-notebook [$NOTEBOOKIP]"
    docker $DOCKERARGS stop $PROJECT-notebook
  ;;
  "remove")
    echo "Removing notebook $PROJECT-notebook [$NOTEBOOKIP]"
    docker $DOCKERARGS rm $PROJECT-notebook
  ;;
  "purge")
    echo "Purging notebook $PROJECT-notebook [$NOTEBOOKIP]"
    rm -R $SRV/notebook
  ;;
  "clean")
    echo "Cleaning base image kooplex-notebook"
    docker $DOCKERARGS rmi kooplex-notebook
  ;;
esac