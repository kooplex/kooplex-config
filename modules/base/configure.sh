#!/bin/bash

DOCKER_HOST=$DOCKERARGS

case $VERB in
    "build")
      echo "Building base image ${PREFIX}-base" >&2
      cp build/Dockerfile $BUILDMOD_DIR
      cp scripts/entrypoint.sh $BUILDMOD_DIR
      cp scripts/bashrc_tail $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-base -f $BUILDMOD_DIR/Dockerfile $BUILDMOD_DIR


   # mkdir -p $SECRETS
   # mkdir -p $KEYS
   # mkdir -p $CONF_DIR
   # mkdir -p $LOG_DIR
   # cp $ORIGINAL_KEYS/*crt $ORIGINAL_KEYS/*key $KEYS/
   # 
   # docker $DOCKERARGS volume create -o type=none -o device=$KEYS -o o=bind ${PREFIX}-keys

   # cp  scripts/* $RF

   # ## CREATE BASE IMAGE
#  #  cp requirements.txt $RF
#  #  cp etc/conda-requirements*.txt $RF
   # cp Dockerfile $RF
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-apt-packages-template > $RF/Dockerfile-base-apt-packages
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-template > $RF/Dockerfile-base-conda
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-extras-template > $RF/Dockerfile-base-conda-extras
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-slurm-template > $RF/Dockerfile-base-slurm
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-singularity-template > $RF/Dockerfile-base-singularity
 
   # docker $DOCKERARGS build -t ${PREFIX}-base  $RF
   # docker $DOCKERARGS build -t ${PREFIX}-base-apt-packages -f $RF/Dockerfile-base-apt-packages  $RF 
   # docker $DOCKERARGS build -t ${PREFIX}-base-conda -f $RF/Dockerfile-base-conda  $RF 
   # docker $DOCKERARGS build -t ${PREFIX}-base-conda-extras -f $RF/Dockerfile-base-conda-extras  $RF 
   # docker $DOCKERARGS build -t ${PREFIX}-base-slurm -f $RF/Dockerfile-base-slurm  $RF 
   # docker $DOCKERARGS build -t ${PREFIX}-base-singularity -f $RF/Dockerfile-base-singularity  $RF 
   # echo "Generating secrets..."

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
