#!/bin/sh

if [ "$REPORT_TYPE" == "bokeh" ] ; then 
    echo "Starting Report Bokeh Server"
    nice -n 19 /usr/local/sbin/preview-bokeh.sh $REPORT_DIR
elif [ "$REPORT_TYPE" == "service" ] ; then 
    echo "Starting Report KernelGateway Server"
    cd $REPORT_DIR
    nice -n 19 /usr/local/sbin/preview-nb-api.sh $REPORT_INDEX
elif [ "$REPORT_TYPE" == "dynamic" ] ; then 
    echo "Starting Notebook Server"
    cd $REPORT_DIR
    echo "Trust notebook"
    jupyter trust $REPORT_INDEX
    nice -n 19 start-notebook.sh --config=/etc/jupyter_report_config.py --NotebookApp.base_url="/${NB_URL}" --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN --notebook-dir=$REPORT_DIR 
else
    echo "Starting notebook for $NB_USER..."
    nice -n 19 start-notebook.sh --config=/etc/jupyter_notebook_config.py --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN --EnvironmentKernelSpecManager.display_name_template=\" {}\" 
fi
