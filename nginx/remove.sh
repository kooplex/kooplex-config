#!/bin/bash

docker stop $PROJECT-nginx
docker rm $PROJECT-nginx
docker rmi nginx

mkdir -p $SRV/nginx/etc/