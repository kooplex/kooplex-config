#! /bin/bash


CONF=/tmp/mount.conf
LOG=/tmp/mount.log
MOUNTER=/usr/local/sbin/manage_mount.sh

if [ ! -x $MOUNTER ] ; then
    echo "$MOUNTER is not executable" > /tmp/mount.err
    exit
fi

if [ -f $CONF ] ; then
   echo "Running mounter" >> $LOG
   $MOUNTER
else
   echo "No config file, creating an empty so that inotifywait can attach to" >> $LOG
   touch $CONF
fi

(
while (true) ; do
    #NOTE: close_wait signal does not work in a docker container overlay fs.
    inotifywait  $CONF 2>> $LOG
    echo "Changes detected" >> $LOG
    $MOUNTER
done
) &
  
echo "inotifywait loop for ${CONF} is in background." >> $LOG

