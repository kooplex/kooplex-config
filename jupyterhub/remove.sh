#!/bin/bash

docker stop $PROJECT-jupyterhub
docker rm $PROJECT-jupyterhub

rm -R $SRV/jupyterhub