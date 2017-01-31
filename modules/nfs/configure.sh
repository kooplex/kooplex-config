#!/bin/bash

case $VERB in
  "install")
    # Create disk image and configure loopback on host if configured so
    if [ -z "$HOME_DISKIMG" ]; then
      echo "Home disk image is unset, skipping image build step"
    else
      echo "Building home disk image..."
      if [ -e $SRV/$HOME_DISKIMG ]; then
        echo "Warning: $HOME_DISKIMG exists!"
        echo "If you want to remove it, please, use remove and purge for complete removal"
      else
        cnt=`echo $HOME_DISKSIZEGB | awk '{print $1*1000}'`
        dd if=/dev/zero of=$SRV/$HOME_DISKIMG bs=1M count=$cnt
        mkfs -t ext4 $SRV/$HOME_DISKIMG
      fi
    fi
    
    mkdir -p $SRV/nfs/etc
    echo "sunrpc 111/tcp portmapper
sunrpc 111/udp portmapper
nfs 2049/tcp
nfs 2049/udp" > $SRV/nfs/etc/services
  
    docker $DOCKERARGS create \
      --name $PROJECT-nfs \
      --hostname $PROJECT-nfs \
      --net $PROJECT-net \
      --ip $NFSIP \
      --privileged \
      -v $SRV/nfs/etc/services:/etc/services:ro \
      -v $SRV/home:/exports/home \
      cpuguy83/nfs-server /exports/home
  ;;
  "start")
    echo "Starting nfs home server $PROJECT-nfs [$NFSIP]"
    
    # Mount home disk image if necessary
    if [ ! -z "$HOME_DISKIMG" ]; then
      if grep -qs $SRV/home /proc/mounts; then
        echo "Warning: $SRV/$HOME_DISKIMG is already mounted to $SRV/home"
      else
        mkdir -p $SRV/home
        # TODO: make this mount permanent in fstab and move to install step
        # TODO: set user quota
        mount $SRV/$HOME_DISKIMG $SRV/home -t auto -o usrquota,grpquota,acl,loop=$HOME_DISKLOOPNO
        # Turn on quota
        touch $SRV/home/quota.user $SRV/home/quota.group
        if [ ! `quotacheck -mcuvgf $SRV/home` ]; then
          quotaon -avug $SRV/home
        fi
      fi
    fi
    
    docker $DOCKERARGS start $PROJECT-nfs
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping nfs home server $PROJECT-nfs [$NFSIP]"
    docker $DOCKERARGS stop $PROJECT-nfs
    
    # Unmount home disk image if necessary
    if [ ! -z "$HOME_DISKIMG" ]; then
      
      # Turn off quota
      quotaoff -vug $SRV/home
      #rm -f $SRV/home/aquota.*
      # TODO: remove permanent mount from fstab and move to remove step
      umount $SRV/home
      rm -R $SRV/home
    fi
  ;;
  "remove")
    echo "Removing nfs home server $PROJECT-nfs [$NFSIP]"
    docker $DOCKERARGS rm $PROJECT-nfs
    rm -R $SRV/nfs
  ;;
  "purge")
    echo "Purging nfs home server $PROJECT-nfs [$NFSIP]"
    
    # Delete home disk image if necessary
    if [ ! -z "$HOME_DISKIMG" ]; then
      rm $SRV/$HOME_DISKIMG
    fi
    
    rm -R $SRV/home
  ;;
esac
