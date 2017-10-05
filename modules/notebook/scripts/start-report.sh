#!/bin/bash

source /etc/bash.bashrc
# source bash initialisation fragments from volumes attached to the container
if [ -d /vol ] ; then
    for rc in /vol/*/bashrc ; do
        . $rc
    done
fi

cd /report
echo "ITT"

export condaenvs=`echo "['"$CONDA_ENV_DIR"']"| sed -e "s/:/','/g"`                                                                                    
echo $CONDA_ENV_DIR                                                                                                                   
echo $condaenvs 
# Start the notebook server
exec su $NB_USER -c "env PATH=$PATH jupyter notebook $* --allow-root --EnvironmentKernelSpecManager.conda_env_dirs=\"$condaenvs\" --EnvironmentKernelSpecManager.display_name_template=\" {}\" --EnvironmentKernelSpecManager.display_name_template=\" {}\""

