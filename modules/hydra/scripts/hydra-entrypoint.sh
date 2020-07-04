#!/bin/sh

exec 2> /var/log/hydra/entry.log
exec 1>&2

date

lockfile=/etc/hydra/.migrated
if [ ! -f $lockfile ]; then
    echo "hydra migrate $DATABASE_URL"
    hydra migrate sql $DATABASE_URL &&  touch $lockfile
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

echo "Start service"
hydra host --dangerous-force-http

echo "Sleeping for infinity, press Ctrl+C ..."
sleep 1000000
