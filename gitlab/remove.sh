#!/bin/bash

docker stop $PROJECT-gitlab
docker rm $PROJECT-gitlab

rm -R $SRV/gitlab/etc
rm -R $SRV/gitlab/log
rm -R $SRV/gitlab/opt