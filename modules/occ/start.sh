#! /bin/bash

env

if [ $UID == 0 ] ; then
    groupadd --gid $S_GID $S_UNAME
    useradd --uid $S_UID --gid $S_GID $S_UNAME
    exec su $S_UNAME -c "/wd.py -c $URL_OWNCLOUD $FOLDER_SYNC"
else
    exec /wd.py -c $URL_OWNCLOUD $FOLDER_SYNC
fi

