#!/bin/bash

IP=$1

echo "Installing nfs home $PROJECT-home [$IP]"

# Initialize nginx directory with necessary config files

mkdir -p $SRV/home

# Install and execute docker image

docker run -d \
  --name $PROJECT-home \
  --net $PROJECT-net \
  --ip $IP \
  --privileged \
  -v $SRV/home:/home \
  cpuguy83/nfs-server /home

