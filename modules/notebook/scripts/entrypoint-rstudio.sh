#!/bin/sh


#!/bin/execlineb -S0

##
## load default PATH (the same that Docker includes if not provided) if it doesn't exist,
## then go ahead with stage1.
## this was motivated due to this issue:
## - https://github.com/just-containers/s6-overlay/issues/108
##
rm /init/99-startnotebookserver.sh

for SCRIPT in /init/*
do
  echo "Running init script: $SCRIPT"
  . $SCRIPT
done

nohup nginx

IDD=`id -u $NB_USER`
usermod -u $IDD -o -d /home/$NB_USER rstudio

CONDA_DIR=/opt/conda

export PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$CONDA_DIR/bin
/etc/s6/init/init-stage1 $@

