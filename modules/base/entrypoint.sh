#!/bin/sh

chmod 0600 /etc/nslcd.conf
exec nslcd &
exec rpcbind &

for SCRIPT in /init/*
do
    . $SCRIPT
done

exec sleep infinity