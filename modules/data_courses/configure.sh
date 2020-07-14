#!/bin/bash

MODULE_NAME=courses

case $VERB in
  "build")
      echo "1. Building ${MODULE_NAME}..."
      
      mkdir -p $SRV/{_course,_usercourse,_assignment,_workdir}
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_course -o o=bind ${PREFIX}-course
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_usercourse -o o=bind ${PREFIX}-usercourse
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_assignment -o o=bind ${PREFIX}-assignment
      docker $DOCKERARGS volume create -o type=none -o device=$SRV/_workdir -o o=bind ${PREFIX}-workdir
  ;;

  "purge")

      docker $DOCKERARGS volume rm ${PREFIX}-course
      docker $DOCKERARGS volume rm ${PREFIX}-assignment
      docker $DOCKERARGS volume rm ${PREFIX}-usercourse
      docker $DOCKERARGS volume rm ${PREFIX}-workdir
  ;;


esac

