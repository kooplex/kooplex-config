#!/bin/sh

for SCRIPT in /init/*
do
  if [ -x $SCRIPT ] ; then
          echo "Running init script: $SCRIPT"
	  $SCRIPT
  else
          echo "Sourcing init script: $SCRIPT"
	  . $SCRIPT
  fi
done

echo "Sleeping for infinity, press Ctrl+C ..."
exec sleep infinity
