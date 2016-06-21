#!/bin/bash

docker stop $PROJECT-nginx
docker rm $PROJECT-nginx

rm -R $SRV/nginx/etc/