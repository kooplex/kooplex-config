#!/bin/bash

# Initialize docker network
echo Creating docker network $PROJECT-net [$SUBNET]

docker $DOCKERARGS network create --driver bridge --subnet $SUBNET $PROJECT-net