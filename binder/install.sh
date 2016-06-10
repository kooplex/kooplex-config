#!/bin/bash

# generate self signed certificates 
cd secrets
./make_ssl.sh
cd ..

# build basebinderimage and binderhub
docker build -f Dockerfile.userimage -t kooplexbindersingleuser  --force-rm .
docker-compose -p kooplexbinder build

