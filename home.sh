#!/bin/bash

CONFIGDIR=$PWD

. ./lib.sh

VERB=$(getverb "$@")

echo "Mounting home loopback file system..."

case $VERB in
  "init")
	cnt=`echo $HOME_DISKSIZEGB | awk '{print $1*1000}'` 
	dd if=/dev/zero of=$SRV/home.img bs=1M count=$cnt 
	mkfs -t ext4 $SRV/home.img
  ;;
  "mount")
    mkdir -p $SRV/home
	mount $SRV/$HOME_DISKIMG $SRV/home -t auto -o usrquota,grpquota,acl,loop=$HOME_DISKLOOPNO
  ;;
  "umount")
    umount $SRV/home
  ;;
esac
