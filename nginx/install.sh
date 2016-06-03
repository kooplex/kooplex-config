#!/bin/bash

IP=$1

echo "Installing nginx $PROJECT-nginx [$IP]"

# Initialize nginx directory with necessary config files

mkdir -p $SRV/nginx/etc/
cp nginx.conf $SRV/nginx/etc/

# Install and execute docker image

docker run -d \
  --name $PROJECT-nginx \
  --net $PROJECT-net \
  --ip $IP \
  -v $SRV/nginx/etc/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $SRV/nginx/etc/sites-enabled/:/etc/nginx/sites-enabled/ \
  nginx
