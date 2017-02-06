#!/bin/bash

CONFIGDIR=$PWD

. ./lib.sh

VERB=$(getverb "$@")

case $VERB in
  "init")
    echo "Creating image file for home..."
	cnt=`echo $HOME_DISKSIZEGB | awk '{print $1*1000}'` 
	dd if=/dev/zero of=$SRV/home.img bs=1M count=$cnt 
	mkfs -t xfs $SRV/home.img
  ;;
  "mount")
    echo "Mounting home loopback file system..."
    mkdir -p $SRV/home
	mount $SRV/$HOME_DISKIMG $SRV/home -t auto -o usrquota,grpquota,acl,loop=$HOME_DISKLOOPNO
  ;;
  "umount")
    umount $SRV/home
  ;;
esac
