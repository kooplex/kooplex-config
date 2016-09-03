#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"

    mkdir -p $DISKIMG
    cnt=`echo $DISKSIZE_GB | awk '{print $1*1000}'`
    dd if=/dev/zero of=$DISKIMG/kooplexfs.img bs=1M count=$cnt
    mkfs -t ext4 $DISKIMG/kooplexfs.img

    mkdir -p $SRV

    mount $DISKIMG/kooplexfs.img $SRV -t auto -o usrquota,grpquota,acl,loop=$LOOPNO
    quotacheck -cuvg $SRV
    quotaon -vu $SRV
    quotaon -vg $SRV
    
    mkdir -p $SECRETS
    docker $DOCKERARGS build -t kooplex-base  .
  ;;
  "install")
  echo "Generating secrets..."
    LDAPPASS=$(createsecret ldap)
  ;;
  "start")
    
  ;;
  "init")
    
  ;;
  "stop")
    
  ;;
  "remove")
  umount $DISKIMG/kooplexfs.img 
  ;;
  "purge")

  ;;
  "clean")
    umount $SRV
    rm -f $DISKIMG/kooplexfs.img 
    echo "Cleaning base image kooplex-base"
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac
