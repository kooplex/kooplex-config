#! /bin/bash

service nslcd restart
/usr/local/bin/patch-davfs.sh

while (true); do
  sleep 3600
done
