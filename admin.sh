#!/bin/bash

docker pull debian

rm -f -r compare_admin_image
mkdir compare_admin_image
cd compare_admin_image

echo "Select the branch which will be used for deployment (press number):"
OPTIONS="master all-in-admin-branch"
select opt in $OPTIONS; do
    if [ "$opt" = "master" ]; then
     BRANCHVAR="master"
     echo "master branch is selected"
     break
    elif [ "$opt" = "all-in-admin-branch" ]; then
     BRANCHVAR="all-in-admin-branch"
     echo "all-in-admin-branch branch is selected"
     break
    else
     echo "Bad option"
	 exit 1
    fi
done

echo "Cloning git repository of kooplex-config..."
git clone --branch $BRANCHVAR https://github.com/kooplex/kooplex-config.git ./kooplex-config
echo "Done"

source ./kooplex-config/config.sh

cd kooplex-config
# Remove previously installed components
. ./remove.sh

cd net
# Initialize docker network
. ./remove.sh
. ./install.sh
. ./init.sh

cd ..

docker build -t compare_admin_image --build-arg BRANCHVAR=$BRANCHVAR --build-arg PROJECT=$PROJECT --build-arg CACHE_DATE=$(date) .
docker run -d -p 32778:22 -v /var/run/docker.sock:/run/docker.sock -v /usr/bin/docker:/bin/docker -v $ROOT:$ROOT --name compare-admin --net $PROJECT-net compare_admin_image
echo "Admin container is running..."
docker exec -it compare-admin /bin/bash -c 'cd /tmp/kooplex-config ; ./install.sh'
docker exec -it compare-admin /bin/bash -c 'cd /tmp/kooplex-config ; ./init.sh'
echo "Installation and initialization are done."
