#!/bin/bash

echo "Installing nfs home $PROJECT-home [$HOMEIP]"

# Initialize nginx directory with necessary config files

mkdir -p $SRV/home

# Install and execute docker image

docker run -d \
  --name $PROJECT-home \
  --net $PROJECT-net \
  --ip $HOMEIP \
  --privileged \
  -v $SRV/home:/home \
  cpuguy83/nfs-server /home

