FROM ideonate/containds-all-basic:0.4.3

USER root
RUN adduser --no-create-home --uid 989 --disabled-password --home /srv report

USER report

RUN which python3

CMD python3 /srv/report/${REPORT_NAME}/${REPORT_INDEX}; sleep 100000 
