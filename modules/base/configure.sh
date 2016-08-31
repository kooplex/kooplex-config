#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"

    mkdir -p $DISKIMG
    dd if=/dev/zero of=$DISKIMG/kooplexfs.img bs=$DISKSIZE count=1
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
