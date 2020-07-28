#!/bin/bash

RF=$BUILDDIR/base
mkdir -p $RF
DOCKER_HOST=$DOCKERARGS

case $VERB in
  "build")
    echo "Building base image ${PREFIX}-base"

    mkdir -p $SECRETS
    mkdir -p $KEYS
    mkdir -p $CONF_DIR
    mkdir -p $LOG_DIR
    cp $ORIGINAL_KEYS/${PREFIX}.{crt,key} $KEYS/ 
    
    docker $DOCKERARGS volume create -o type=none -o device=$KEYS -o o=bind ${PREFIX}-keys
    docker $DOCKERARGS volume create -o type=none -o device=$SECRETS -o o=bind ${PREFIX}-secrets

    cp  scripts/* $RF

    ## CREATE BASE IMAGE
#    cp requirements.txt $RF
#    cp etc/conda-requirements*.txt $RF
    cp Dockerfile $RF
    sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-apt-packages-template > $RF/Dockerfile-base-apt-packages
    docker $DOCKERARGS build -t ${PREFIX}-base  $RF
    docker $DOCKERARGS build -t ${PREFIX}-base-apt-packages -f $RF/Dockerfile-base-apt-packages  $RF 

    if [ ! ${IMAGE_REPOSITORY_URL} ]; then
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-template > $RF/Dockerfile-base-conda
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-slurm-template > $RF/Dockerfile-base-slurm
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-singularity-template > $RF/Dockerfile-base-singularity
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-extras-template > $RF/Dockerfile-base-conda-extras
 
        docker $DOCKERARGS build -t ${PREFIX}-base-slurm -f $RF/Dockerfile-base-slurm  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-base-singularity -f $RF/Dockerfile-base-singularity  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-base-conda -f $RF/Dockerfile-base-conda  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-base-conda-extras -f $RF/Dockerfile-base-conda-extras  $RF 
    fi

  ;;
  "install")

  ;;
  "start")
    
  ;;
  "init")
    
  ;;
  "stop")
    
  ;;
  "remove")

  ;;
  "purge")
    echo "Cleaning base folder $SRV/; Remove aquota"
#  quotaoff -vu $SRV
#  quotaoff -vg $SRV
#  rm -f $SRV/aquota.*

    docker $DOCKERARGS volume rm ${PREFIX}-secrets
    docker $DOCKERARGS volume rm ${PREFIX}-keys
    docker $DOCKERARGS rmi ${PREFIX}-base-slurm 
    docker $DOCKERARGS rmi ${PREFIX}-base-singularity 
    docker $DOCKERARGS rmi ${PREFIX}-base-conda 
    docker $DOCKERARGS rmi ${PREFIX}-base-conda-extras

  ;;
  "clean")
    echo "Cleaning base image ${PREFIX}-base"

    rm -r $SRV/.secrets
    rm -r $RF
  ;;
esac
