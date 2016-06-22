#!/bin/bash

echo "Building docker image kooplex-base"

mkdir etc
cp -R ../../etc/* etc/

# Build docker image

docker $DOCKERARGS build -t kooplex-base  .

rm -R etc