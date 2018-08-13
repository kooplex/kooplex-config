#!/bin/sh

if [ -z "$REPORT_FILE" ] ; then 
    echo "Starting notebook for $NB_USER..."
    . start-notebook.sh --config=/etc/jupyter_notebook_config.py --log-level=DEBUG --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN
else
    echo "Starting Report Server"
    . start-report.sh --allow-root --config=/etc/jupyter_report_config.py --log-level=DEBUG --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN
fi
