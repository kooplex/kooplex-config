#!/bin/bash

MODULE_NAME=base
RF=$BUILDDIR/${MODULE_NAME}
mkdir -p $RF
DOCKER_HOST=$DOCKERARGS

case $VERB in
  "build")
    echo "Building base image ${PREFIX}-base"

    mkdir -p $SECRETS $KEYS $CONF_DIR $LOG_DIR
    cp $ORIGINAL_KEYS/${PREFIX}.{crt,key} $KEYS/ 
    
    docker $DOCKERARGS volume create -o type=none -o device=$KEYS -o o=bind ${PREFIX}-keys
    docker $DOCKERARGS volume create -o type=none -o device=$SECRETS -o o=bind ${PREFIX}-secrets


    IMAGENAME=base
    if [ ! ${PULL_IMAGE_FROM_REPOSITORY} ]; then
             cp  scripts/* $RF
             cp Dockerfile $RF
             docker $DOCKERARGS build -t ${PREFIX}-base  $RF
             docker $DOCKERARGS tag ${PREFIX}-base ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}base:${IMAGE_REPOSITORY_VERSION}
             sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-apt-packages-template > $RF/Dockerfile-base-apt-packages
             docker $DOCKERARGS build -t ${PREFIX}-base-apt-packages -f $RF/Dockerfile-base-apt-packages  $RF 
#    else
#	     echo "Using images from $IMAGE_REPOSITORY_URL"
#             IMAGE_TO_PULL=$IMAGE_REPOSITORY_URL"/"kooplex-base-${IMAGENAME}
#             docker $DOCKERARGS pull $IMAGE_TO_PULL
#	     echo "Image PULLED from repository"
#             docker tag $IMAGE_TO_PULL ${PREFIX}-${IMAGENAME}
#	     echo "Image TAGGED from repository"
    fi


    if [ ! ${PULL_IMAGE_FROM_REPOSITORY} ]; then
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-template > $RF/Dockerfile-base-conda
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-slurm-template > $RF/Dockerfile-base-slurm
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-singularity-template > $RF/Dockerfile-base-singularity
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-extras-template > $RF/Dockerfile-base-conda-extras
        sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-notebook-base-template > $RF/Dockerfile-notebook-base
 
        docker $DOCKERARGS build -t ${PREFIX}-base-slurm -f $RF/Dockerfile-base-slurm  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-base-singularity -f $RF/Dockerfile-base-singularity  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-base-conda -f $RF/Dockerfile-base-conda  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-base-conda-extras -f $RF/Dockerfile-base-conda-extras  $RF 
        docker $DOCKERARGS build -t ${PREFIX}-notebook-base -f $RF/Dockerfile-notebook-base  $RF 
        docker $DOCKERARGS tag ${PREFIX}-notebook-base ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}notebook-base:${IMAGE_REPOSITORY_VERSION}
        if [ ${IMAGE_REPOSITORY_URL} ]; then
              docker $DOCKERARGS tag ${PREFIX}-notebook-base ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}notebook-base:${IMAGE_REPOSITORY_VERSION}
              docker $DOCKERARGS push ${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}notebook-base:${IMAGE_REPOSITORY_VERSION}
        fi 
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
    rm -r $RF

    docker $DOCKERARGS volume rm ${PREFIX}-secrets
    docker $DOCKERARGS volume rm ${PREFIX}-keys
    docker $DOCKERARGS rmi ${PREFIX}-base-slurm 
    docker $DOCKERARGS rmi ${PREFIX}-base-singularity 
    docker $DOCKERARGS rmi ${PREFIX}-base-conda 
    docker $DOCKERARGS rmi ${PREFIX}-base-conda-extras

  ;;
  "clean")
    echo "Cleaning base image ${PREFIX}-base"

    rm -r $SECRETS
  ;;
esac
