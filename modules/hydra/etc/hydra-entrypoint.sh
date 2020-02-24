#!/bin/sh
echo $DATABASE_URL > /tmp/vmi

lockfile=/.migrated
if [ ! -f $lockfile ]; then 
    hydra migrate sql $DATABASE_URL &&  touch $lockfile
    echo hydra migrate $DATABASE_URL &&  touch $lockfile
    echo "Migrated"
fi

for SCRIPT in /init/*
do
  echo "Running init script: $SCRIPT"
  if [ -x $SCRIPT ] ; then
	  $SCRIPT
  else
	  . $SCRIPT
  fi
done

hydra host --dangerous-force-http

echo "Sleeping for infinity, press Ctrl+C ..."
exec sleep infinity
