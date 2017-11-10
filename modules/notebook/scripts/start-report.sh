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
echo "PASS: "$PASSWORD
export condaenvs=`echo "['"$CONDA_ENV_DIR"']"| sed -e "s/:/','/g"`                                                                                    
echo $CONDA_ENV_DIR                                                                                                                   
echo $condaenvs 
# Start the notebook server
exec su $NB_USER -c "env PATH=$PATH jupyter report-kooplex $* --allow-root --NotebookApp.iopub_data_rate_limit=1.0e10 --EnvironmentKernelSpecManager.conda_env_dirs=\"$condaenvs\" --EnvironmentKernelSpecManager.display_name_template=\" {}\" --EnvironmentKernelSpecManager.display_name_template=\" {}\""

