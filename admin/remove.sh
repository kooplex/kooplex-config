#!/bin/bash

docker stop $PROJECT-admin
docker rm $PROJECT-admin

rm -R $SRV/admin/etc
rm -R $SRC/kooplex-config
