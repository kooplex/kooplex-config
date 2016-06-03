#!/bin/bash

docker stop $PROJECT-home
docker rm $PROJECT-home

rm -R $SRV/home