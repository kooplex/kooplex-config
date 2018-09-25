#! /bin/bash


MOUNTER=/usr/local/sbin/manage_mount.sh
if [ ! -x $MOUNTER ] ; then
  echo "$MOUNTER is not executable" > /tmp/mount.err
  exit
fi

for target in report workdir share ; do

  CONF=/tmp/mount_${target}.conf
  LOG=/tmp/mount_${target}.log

  echo $0 > $LOG


  if [ -f $CONF ] ; then
   echo "Running mounter" >> $LOG
   $MOUNTER ${target}
  else
   echo "No config file, creating an empty so that inotifywait can attach to" >> $LOG
   touch $CONF
  fi


  (
  while (true) ; do
    #NOTE: close_wait signal does not work in a docker container overlay fs.
    inotifywait  $CONF 2>> $LOG
    echo "Changes detected" >> $LOG
    $MOUNTER ${target}
  done
  ) &
  
  echo "inotifywait loop for ${target} is in background." >> $LOG

done
