#!/bin/sh


#!/bin/execlineb -S0

##
## load default PATH (the same that Docker includes if not provided) if it doesn't exist,
## then go ahead with stage1.
## this was motivated due to this issue:
## - https://github.com/just-containers/s6-overlay/issues/108
##

for SCRIPT in /init/*
do
    if [ -x $SCRIPT ] ; then
        echo "Running init script: $SCRIPT"
        $SCRIPT
    elif [ -f $SCRIPT ] ; then
        echo "Sourcing init script: $SCRIPT"
        . $SCRIPT
    else
        echo "Not a file $SCRIPT"
    fi
done

nohup nginx

IDD=`id -u $NB_USER`
usermod -u $IDD -o -d /v/ rstudio

CONDA_DIR=/opt/conda

export PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$CONDA_DIR/bin

sudo -u rstudio env -u 1000 -u 1000 /usr/lib/rstudio-server/bin/rserver --auth-none=1 --auth-validate-users=0  --auth-stay-signed-in-days=30

sleep infinity

#/etc/s6/init/init-stage1 $@

