#!/bin/bash

# Enable sudo if requested
if [ ! -z "$GRANT_SUDO" ]; then
    echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
fi

# Start the notebook server
exec su $NB_USER -c "cd /v ; env PATH=$PATH jupyter notebook-kooplex $* --NotebookApp.iopub_data_rate_limit=1.0e10 --EnvironmentKernelSpecManager.display_name_template=\" {}\" "

# clean up
