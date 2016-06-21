#!/bin/bash

docker stop $PROJECT-owncloud
docker rm $PROJECT-owncloud

rm -r $SRV/owncloud/apps
rm -r $SRV/owncloud/config
rm -r $SRV/owncloud/data