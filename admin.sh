#!/bin/bash

docker pull debian

rm -f -r compare_admin_image
mkdir compare_admin_image
cd compare_admin_image

echo "Select the branch which should be used for deployment:"
OPTIONS="master branch"
select opt in $OPTIONS; do
    if [ "$opt" = "master" ]; then
     BRANCHVAR="master"
     echo "master branch is selected"
     break
    elif [ "$opt" = "branch" ]; then
     BRANCHVAR="all-in-admin-branch"
     echo "all-in-admin-branch branch is selected"
     break
    else
     echo "Bad option"
	 exit 1
    fi
done

echo "Downloading Dockerfile and config.sh..."
wget https://raw.githubusercontent.com/eltevo/compare-config/$BRANCHVAR/Dockerfile
wget https://raw.githubusercontent.com/eltevo/compare-config/$BRANCHVAR/config.sh
wget https://raw.githubusercontent.com/eltevo/compare-config/$BRANCHVAR/net/install.sh
wget https://raw.githubusercontent.com/eltevo/compare-config/$BRANCHVAR/net/init.sh
echo "Done"

source config.sh

# Initialize docker network
. ./init.sh
. ./install.sh

docker build -t compare_admin_image --build-arg BRANCHVAR=$BRANCHVAR .
docker run -d -p 32778:22 -v /var/run/docker.sock:/run/docker.sock -v /usr/bin/docker:/bin/docker --name compare-admin --net $PROJECT-net compare_admin_image
