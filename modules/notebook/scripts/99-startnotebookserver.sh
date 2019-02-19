#!/bin/sh

if [ "$REPORT_TYPE" == "bokeh" ] ; then 
    echo "Starting Report Bokeh Server"
    nice -n 19 /usr/local/bin/preview-bokeh.sh $REPORT_DIR
elif [ "$REPORT_TYPE" == "jupyter" ] ; then 
    echo "Starting Report KernelGateway Server"
    nice -n 19 /usr/local/bin/preview-nb-api.sh $REPORT_DIR
else
    echo "Starting notebook for $NB_USER..."
    nice -n 19 start-notebook.sh --config=/etc/jupyter_notebook_config.py --log-level=DEBUG --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN
fi
