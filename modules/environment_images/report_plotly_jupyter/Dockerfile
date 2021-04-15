#FROM lukauskas/bokeh:latest
FROM danielperezr88/bokeh-python3:latest

RUN pip install --upgrade pip
RUN pip install  jupyter jupyter-dash dash-auth dash-bootstrap-components dash-core-components  dash-renderer


RUN adduser  --uid 989 --disabled-password --home /v report
ADD jupyter_report_config.py /tmp/jupyter_report_config.py
USER report

RUN echo "cd /srv/report/\${REPORT_NAME} ; env PATH=$PATH jupyter notebook /srv/report/\${REPORT_NAME}/\${REPORT_INDEX} --NotebookApp.iopub_data_rate_limit=1.0e10   --NotebookApp.base_url=\$NB_URL --NotebookApp.port=\$REPORT_PORT --NotebookApp.token=\$NB_TOKEN --config=/tmp/jupyter_report_config.py --notebook-dir=/srv/report/${REPORT_NAME}; sleep infinity" > /tmp/init.sh && chmod a+x /tmp/init.sh

jupyter-kernelgateway --KernelGatewayApp.port=$REPORT_PORT --KernelGatewayApp.api=notebook-http --KernelGatewayApp.ip=0.0.0.0 --KernelGatewayApp.allow_origin=* --KernelGatewayApp.seed_uri=$1 --KernelGatewayApp.base_url="\${NB_URL}/"

CMD ["/tmp/init.sh"]

