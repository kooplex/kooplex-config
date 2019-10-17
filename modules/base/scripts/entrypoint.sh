#!/bin/sh

for SCRIPT in /init/*
do
  echo "Running init script: $SCRIPT"
  if [ -x $SCRIPT ] ; then
	  $SCRIPT
  else
	  . $SCRIPT
  fi
done

echo "Sleeping for infinity, press Ctrl+C ..."
exec sleep infinity
