#!/bin/bash

echo "Initializing admin $PROJECT-admin [$ADMINIP]"

echo "Mounting NFS home"
mount -t nfs -o proto=tcp,port=2049 $HOMEIP:/home /home