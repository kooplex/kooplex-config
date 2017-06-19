#!/bin/bash

case $VERB in
  "build")
    echo "Building base image kooplex-base"

# TODO make optional 
#  if [ -e $DISKIMG/$PROJECT"fs.img" ]; then
#   echo WARNING $DISKIMG/$PROJECT"fs.img exists!!"
#   echo "If you want to remove it, please, use remove and purge for complete removal"
#  else
#   mkdir -p $DISKIMG
 #  cnt=`echo $DISKSIZE_GB | awk '{print $1*1000}'`
#    dd if=/dev/zero of=$DISKIMG/$PROJECT"fs.img" bs=1M count=$cnt
#    mkfs -t ext4 $DISKIMG/$PROJECT"fs.img"
#  fi
#  
#  if grep -qs "$SRV" /proc/mounts; then
#    echo $DISKIMG/$PROJECT"fs.img is already mounted to $SRV"  
#  else
#      mkdir -p $SRV
#      mount $DISKIMG/$PROJECT"fs.img" $SRV -t auto -o usrquota,grpquota,acl,loop=$LOOPNO
#  fi
    
     mkdir -p $SECRETS
#     if [ ! `quotacheck -mcuvgf $SRV` ]; then
#       quotaon -vu $SRV
#       quotaon -vg $SRV
#     fi
    
   
    docker $DOCKERARGS build -t kooplex-base  .
    echo "Generating secrets..."
    LDAPPASS=$(createsecret ldap)
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
  quotaoff -vu $SRV
  quotaoff -vg $SRV
  rm -f $SRV/aquota.*
  rm -r $SRV/.secrets
  ;;
  "clean")
    echo "Cleaning base image kooplex-base"
    #umount $SRV 
    echo "Check if $SRV is still mounted! Then run: ' rm -f "$DISKIMG/$PROJECT"fs.img '" 
    #rm -f $DISKIMG/$PROJECT"fs.img" 
    docker $DOCKERARGS rmi kooplex-base
  ;;
esac
