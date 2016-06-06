#!/bin/bash

echo "Installing gitlab $PROJECT-gitlab [$GITLABIP]"

# Initialize gitlab directories and preparing config files

mkdir -p $SRV/gitlab/etc
mkdir -p $SRV/gitlab/log
mkdir -p $SRV/gitlab/opt

# Install and execute docker image

docker run -d \
  --name $PROJECT-gitlab \
  --net $PROJECT-net \
  --ip $GITLABIP \
  -v $SRV/gitlab/etc:/etc/gitlab \
  -v $SRV/gitlab/log:/var/log/gitlab \
  -v $SRV/gitlab/opt:/var/opt/gitlab \
  gitlab/gitlab-ce:latest

sleep 5

. ./configure.sh