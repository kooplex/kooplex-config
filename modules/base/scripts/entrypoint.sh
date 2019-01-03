#!/bin/sh

for SCRIPT in /init/*
do
  echo "Running init script: $SCRIPT"
  . $SCRIPT
done

echo "Sleeping for infinity, press Ctrl+C ..."
exec sleep infinity