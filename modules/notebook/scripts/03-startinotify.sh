#! /bin/bash

CONF=/tmp/mount_report.conf
MOUNTER=/usr/local/sbin/manage_report_mount.sh
LOG=/tmp/mount_report.log

echo $0 > $LOG

if [ ! -x $MOUNTER ] ; then
  echo "$MOUNTER is not executable" >> $LOG
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

echo "inotifywait loop is in background." >> $LOG

