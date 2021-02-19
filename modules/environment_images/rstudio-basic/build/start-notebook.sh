#!/bin/bash

# debug
env
id $NB_USER

# Start the notebook server
#exec su $NB_USER -c "cd /home ; env PATH=$PATH jupyter notebook-kooplex $* --NotebookApp.iopub_data_rate_limit=1.0e10 --EnvironmentKernelSpecManager.display_name_template=\" {}\" "
exec su $NB_USER -c "cd /v ; env PATH=$PATH jupyter notebook-kooplex $* --NotebookApp.iopub_data_rate_limit=1.0e10 "
