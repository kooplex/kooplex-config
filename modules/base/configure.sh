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
  fi
  
  if grep -qs "$SRV" /proc/mounts; then
    echo "$DISKIMG/kooplexfs.img is already mounted to $SRV"  
  else
      mkdir -p $SRV
      mount $DISKIMG/kooplexfs.img $SRV -t auto -o usrquota,grpquota,acl,loop=$LOOPNO

     mkdir -p $SECRETS
  fi
    
    
     quotacheck -cuvg $SRV
     quotaon -vu $SRV
     quotaon -vg $SRV
    
   
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
  echo "Cleaning base folder $SRV/; Remove aquota"
  quotaoff -vu $SRV
  quotaoff -vg $SRV
  rm -f $SRV/aquota.*

  ;;
  "clean")
    echo "Cleaning base image kooplex-base"
    #umount $SRV 
    echo "Check if $SRV is still mounted! Then run: ' rm -f $DISKIMG/kooplexfs.img '" 
    #rm -f $DISKIMG/kooplexfs.img 
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac
