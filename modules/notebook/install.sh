#!/bin/bash

echo "Installing notebook $PROJECT-notebook [$NOTEBOOKIP]"

# Prepare config files

cpetc

mkdir -p $SRV/notebook/etc
cp etc/nslcd.conf $SRV/notebook/etc

# Install and execute docker image

docker $DOCKERARGS build -t kooplex-notebook  .

docker $DOCKERARGS run -d \
  --name $PROJECT-notebook \
  --hostname $PROJECT-notebook \
  --net $PROJECT-net \
  --ip $OWNCLOUDIP \
  -v $SRV/notebook/etc/nslcd.conf:/etc/nslcd.conf \
  kooplex-notebook

rmetc