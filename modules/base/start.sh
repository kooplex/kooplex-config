#!/bin/sh

chmod 0600 /etc/nslcd.conf
exec nslcd &
exec sleep infinity