#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"

  if [ -e $DISKIMG/kooplexfs.img ]; then
   echo "WARNING $DISKIMG/kooplexfs.img exists!!"
   echo "If you want to remove it, please, use remove and purge for complete removal"
  else
    mkdir -p $DISKIMG
    cnt=`echo $DISKSIZE_GB | awk '{print $1*1000}'`
    dd if=/dev/zero of=$DISKIMG/kooplexfs.img bs=1M count=$cnt
    mkfs -t ext4 $DISKIMG/kooplexfs.img

    mkdir -p $SRV

    mount $DISKIMG/kooplexfs.img $SRV -t auto -o usrquota,grpquota,acl,loop=$LOOPNO
    quotacheck -cuvg $SRV
    quotaon -vu $SRV
    quotaon -vg $SRV
  fi
    
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
  umount $SRV 
  echo "Check if $SRV is still mounted! Then run: ' rm -f $DISKIMG/kooplexfs.img '" 
  #rm -f $DISKIMG/kooplexfs.img 

  ;;
  "clean")
    echo "Cleaning base image kooplex-base"
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac
