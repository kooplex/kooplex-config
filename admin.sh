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

echo "Cloning git repository of compare-config..."
git clone --branch $BRANCHVAR https://github.com/eltevo/compare-config.git ./compare-config
echo "Done"

source ./compare-config/config.sh

cd compare-config
# Remove previously installed components
. ./remove.sh

cd net
# Initialize docker network
. ./remove.sh
. ./install.sh
. ./init.sh

cd ..

docker build -t compare_admin_image --build-arg BRANCHVAR=$BRANCHVAR .
docker run -d -p 32778:22 -v /var/run/docker.sock:/run/docker.sock -v /usr/bin/docker:/bin/docker -v $ROOT:$ROOT --name compare-admin --net $PROJECT-net compare_admin_image
echo "Admin container is running..."
docker exec -it compare-admin /bin/bash /tmp/compare-config/install.sh
docker exec -it compare-admin /bin/bash /tmp/compare-config/init.sh
echo "Installation and initialization is done in the admin container."
