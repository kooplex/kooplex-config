#FROM lukauskas/bokeh:latest
FROM danielperezr88/bokeh-python3:latest

RUN adduser --no-create-home --uid 989 --disabled-password --home /srv/report/ report

USER report

CMD cd /srv/report/${REPORT_NAME}; bokeh serve \
    --allow-websocket-origin="*" \
    --prefix /report/$REPORT_NAME \
    --port $REPORT_PORT \
    /srv/report/${REPORT_NAME}/${REPORT_INDEX}


