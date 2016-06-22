#!/bin/bash

case $VERB in
  "install")
    cpetc
    
    echo "Installing image kooplex-notebook"
    
    docker $DOCKERARGS build -t kooplex-notebook  .
    
    echo "Installing notebook $PROJECT-notebook [$NOTEBOOKIP]"
    
    mkdir -p $SRV/notebook/etc
    cp etc/nslcd.conf $SRV/notebook/etc
    
    docker $DOCKERARGS create \
      --name $PROJECT-notebook \
      --hostname $PROJECT-notebook \
      --net $PROJECT-net \
      --ip $OWNCLOUDIP \
      -v $SRV/notebook/etc/nslcd.conf:/etc/nslcd.conf \
      kooplex-notebook
    
    rmetc
  ;;
  "start")
    echo "Starting notebook $PROJECT-notebook [$NOTEBOOKIP]"
    docker $DOCKERARGS start $PROJECT-notebook
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
    rm -R $SRV/notebook/etc
    echo "Purging base image kooplex-notebook"
    docker $DOCKERARGS rmi kooplex-notebook
  ;;
esac