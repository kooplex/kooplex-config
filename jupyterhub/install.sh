#!/bin/bash

echo "Installing jupyterhub $PROJECT-jupyterhub [$JUPYTERHUBIP]"

# Initialize jupyterhub directories and prepare config files

mkdir -p $SRV/jupyterhub

# Install and execute docker image

docker build -t jupyterhub-compare .

docker run -d \
  --name $PROJECT-jupyterhub \
  --net $PROJECT-net \
  --ip $JUPYTERHUBIP \
  -v $SRV/jupyterhub:/srv/jupyterhub \
  jupyterhub-compare

