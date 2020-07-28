# Plugin
Set up alerts for checking webpages, whether they are online or not
Worldping
* You need to have a Grafana API key for this

Publish dashboards (this needs to be made manually for now)
* Endpoints - checks whether wbpages are online
http://kooplex-test.elte.hu/grafana/dashboard/snapshot/UP5rekVtxxBIUvDgp0lx4A4sRLagDrBu

OAUTH for grafana
https://grafana.com/docs/grafana/latest/auth/generic-oauth/

# How to setup
###
Setup grafana to receive data from prometheus
Add datasource prometheus
http://##PREFIX##-prometheus:9090
e.g. http://kooplex-test-prometheus:9090
Them import dashboard
https://grafana.com/grafana/dashboards/893

## TODO
# --storage.tsdb.retention=30d to executable
