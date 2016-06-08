#!/bin/bash

docker pull debian

mkdir compare_admin_image
cd compare_admin_image

source config.sh

echo "Downloading Dockerfile and config.sh..."
wget https://raw.githubusercontent.com/eltevo/compare-config/$BRANCHVAR/Dockerfile
wget https://raw.githubusercontent.com/eltevo/compare-config/$BRANCHVAR/config.sh
echo "Done"

# Initialize docker network
echo Creating docker network $PROJECT-net [$SUBNET]

docker network create --driver bridge --subnet $SUBNET $PROJECT-net

docker build -t compare_admin_image --build-arg BRANCHVAR=$BRANCHVAR --build-arg PROJECT=$PROJECT --build-arg ROOT=$ROOT --build-arg SUBNET=$SUBNET --build-arg DOMAIN=$DOMAIN --build-arg SMTP=$SMTP --build-arg EMAIL=$EMAIL --build-arg DUMMYPASS=$DUMMYPASS .
docker run -d -p 32778:22 -v /var/run/docker.sock:/run/docker.sock -v /usr/bin/docker:/bin/docker --name compare-admin --net $PROJECT-net compare_admin_image