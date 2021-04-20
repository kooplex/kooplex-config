#!/bin/bash

DOCKER_HOST=$DOCKERARGS

case $VERB in
    "buildimage")
      echo "Building base image ${PREFIX}-base" >&2
      cp build/Dockerfile-base $BUILDMOD_DIR
      cp scripts/entrypoint.sh $BUILDMOD_DIR
      cp scripts/01-nslcd $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-base -f $BUILDMOD_DIR/Dockerfile-base $BUILDMOD_DIR
      docker $DOCKERARGS tag ${PREFIX}-base ${MY_REGISTRY}/${PREFIX}-base
      docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-base
    ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;


esac
