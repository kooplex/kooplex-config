#!/bin/bash

#if [ -z "$REPORT_TYPE" ] ; then
#    echo "Starting notebook for $NB_USER..."
#    nice -n 19 /usr/local/bin/start-notebook.sh --config=/etc/jupyter_notebook_config.py --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN --EnvironmentKernelSpecManager.display_name_template=\" {}\" 
#elif [ "${REPORT_TYPE}" == "bokeh" ]; then 
#    echo "Starting Report Bokeh Server"
#    cd $REPORT_DIR
#    nice -n 19 /usr/local/sbin/preview-bokeh.sh $REPORT_INDEX
#elif [ "${REPORT_TYPE}" == "plotly_dash" ]; then 
#    echo "Starting Report Plotly Dash"
#    cd $REPORT_DIR
#    nice -n 19 /bin/bash /usr/local/sbin/report-dash.sh $REPORT_INDEX
#elif [ "${REPORT_TYPE}" == "service" ]; then 
#    echo "Starting Report KernelGateway Server"
#    cd $REPORT_DIR
#    nice -n 19 /usr/local/sbin/preview-nb-api.sh $REPORT_INDEX


if [ "${REPORT_TYPE}" == "dynamic" ]; then 
    echo "Starting Notebook Server (report)"
    cd $REPORT_DIR
    echo "Trust notebook"
    jupyter trust $REPORT_INDEX
    nice -n 19 /usr/local/bin/start-notebook.sh --config=/etc/jupyter_report_config.py --NotebookApp.base_url="/${NB_URL}" --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN --notebook-dir=$REPORT_DIR 
else
    echo "Starting notebook for $NB_USER..."
    nice -n 19 /usr/local/bin/start-notebook.sh --config=/etc/jupyter_notebook_config.py --NotebookApp.base_url=$NB_URL --NotebookApp.port=$NB_PORT --NotebookApp.token=$NB_TOKEN --EnvironmentKernelSpecManager.display_name_template=\" {}\" 
fi
