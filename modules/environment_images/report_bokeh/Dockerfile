FROM bokeh/demo.bokeh.org:latest

RUN adduser --no-create-home --uid 989 --disabled-password --home /v report

USER report

CMD bokeh serve \
    --allow-websocket-origin="*" \
    --index=/index.html \
    --prefix /report/$REPORT_NAME \
    --port $REPORT_PORT \
    /srv/report/${REPORT_NAME} #/${REPORT_INDEX}

