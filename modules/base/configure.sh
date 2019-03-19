#!/bin/bash

RF=$BUILDDIR/base
mkdir -p $RF
DOCKER_HOST=$DOCKERARGS

case $VERB in
  "build")
    echo "Building base image ${PREFIX}-base"

    mkdir -p $SECRETS
    cp  scripts/* $RF
    cp requirements.txt $RF
    cp Dockerfile $RF
    sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-apt-packages-template > $RF/Dockerfile-base-apt-packages
    sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-template > $RF/Dockerfile-base-conda
 
    docker $DOCKERARGS build -t ${PREFIX}-base  $RF
    docker $DOCKERARGS build -t ${PREFIX}-base-apt-packages -f $RF/Dockerfile-base-apt-packages  $RF 
    docker $DOCKERARGS build -t ${PREFIX}-base-conda -f $RF/Dockerfile-base-conda  $RF 
    echo "Generating secrets..."

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
  rm -r $SRV/.secrets
  ;;
  "clean")
    echo "Cleaning base image ${PREFIX}-base"
    #umount $SRV 
#    echo "Check if $SRV is still mounted! Then run: ' rm -f "$DISKIMG/$PROJECT"fs.img '" 
    #rm -f $DISKIMG/$PROJECT"fs.img" 
    docker $DOCKERARGS rmi ${PREFIX}-base
  ;;
esac
