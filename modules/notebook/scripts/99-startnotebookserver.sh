#!/bin/sh

if [ "$REPORT_TYPE" == "bokeh" ] ; then 
    echo "Starting Report Bokeh Server"
    nice -n 19 /usr/local/sbin/preview-bokeh.sh $REPORT_DIR
elif [ "$REPORT_TYPE" == "service" ] ; then 
    echo "Starting Report KernelGateway Server"
    cd $REPORT_DIR
    nice -n 19 /usr/local/sbin/preview-nb-api.sh $REPORT_INDEX
else
    echo "Starting notebook for $NB_USER..."
    nice -n 19 start-notebook.sh --config=/etc/jupyter_notebook_config.py --log-level=DEBUG --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN
fi
