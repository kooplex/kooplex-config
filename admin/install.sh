#!/bin/bash

# build image for administering Kooplex

mkdir -p $SRV/admin/etc
mkdir -p $SRC/kooplex-config

echo "Copying config to $SRC/kooplex-config"
echo "If necessary, modify settings at this new location"

cp -R ../* $SRC/kooplex-config

echo "Building admin docker image..."

docker build -t $PROJECT-admin \
  --build-arg PROJECT=$PROJECT .

echo "Starting admin docker container..."
  
docker run -d --ip $ADMINIP \
  --name $PROJECT-admin \
  --hostname $PROJECT-admin \
  --net $PROJECT-net \
  -v /var/run/docker.sock:/run/docker.sock \
  -v /usr/bin/docker:/bin/docker \
  -v $ROOT/$PROJECT:$ROOT/$PROJECT \
  $PROJECT-admin
  
echo "Admin container is running. SSH to $ADMINIP or execute "
echo "'docker exec -ti $PROJECT-admin bash'"
echo "to finish installation from inside the container."

