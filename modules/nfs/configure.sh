#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-nfs"
    docker $DOCKERARGS build -t kooplex-nfs .
  ;;
  "install")	
	mkdir -p $SRV/nfs/init
	echo "
set -e
	
mkdir -p /exports/home
mount /home.img /exports/home -t xfs -o prjquota,loop=/dev/loop3

exec runsvdir /etc/sv
" > $SRV/nfs/init/1.sh
 
	mkdir -p $SRV/nfs/etc
	echo "/exports/home *(rw,sync,no_subtree_check,fsid=0,no_root_squash)" > $SRV/nfs/etc/exports
	
	touch $SRV/nfs/etc/projects $SRV/nfs/etc/projid
  
    docker $DOCKERARGS create \
      --name $PROJECT-nfs \
      --hostname $PROJECT-nfs \
      --net $PROJECT-net \
      --ip $NFSIP \
      --privileged \
	  -v $SRV/home.img:/home.img \
	  -v $SRV/nfs/init:/init \
	  -v $SRV/nfs/etc/exports:/etc/exports \
      -v $SRV/nfs/etc/projects:/etc/projects \
	  -v $SRV/nfs/etc/projid:/etc/projid \
      kooplex-nfs
  ;;
  "start")
    echo "Starting nfs home server $PROJECT-nfs [$NFSIP]"
    docker $DOCKERARGS start $PROJECT-nfs
	
	echo "Mounting NFS-share locally..."
	mkdir -p $SRV/home
	mount $NFSIP:/exports/home $SRV/home
  ;;
  "init")

  ;;
  "check")
    echo "Checking NFS exports..."
	showmount -e $NFSIP
	echo "Checking quota..."
	docker $DOCKERARGS exec -ti $PROJECT-nfs xfs_quota -x -c "report"
  ;;
  "stop")
    echo "Stopping nfs home server $PROJECT-nfs [$NFSIP]"
	
	# Unmount the local NFS mount
	umount $SRV/home
	rm -R $SRV/home
	
	# Unmount home disk image
    docker $DOCKERARGS exec -ti $PROJECT-nfs umount /exports/home
	
    docker $DOCKERARGS stop $PROJECT-nfs
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
  "clean")
    echo "Cleaning image kooplex-nfs"
    docker $DOCKERARGS rmi kooplex-nfs
  ;;
esac
