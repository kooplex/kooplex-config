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


## Setup api key and add dashboards and panels
curl -X POST -H "Content-Type: application/json" -d '{"name":"apiorg"}' https://admin:$DUMMYPASS@$OUTERHOST/grafana/api/orgs

curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeycurl", "role": "Admin"}' https://admin:$DUMMYPASS@$OUTERHOST/grafana/api/auth/keys > /tmp/api_key

API_KEY=`cat /tmp/api_key`
### Now we have the api key
curl -H "Authorization: Bearer $API_KEY" https://$OUTERHOST/grafana/api/datasources | python -m json.tool


## Add new panel
#curl -X POST -H "Content-Type:application/json" -H "Authorization: Bearer $API_KEY" https://$OUTERHOST/grafana/api/dashboards/db --data "@init/new-panel"
cat init/new-panel-user-template | sed -e "s/##NB_USER##/<user_name>" > /tmp/new-panel
curl -X POST -H "Content-Type:application/json" -H "Authorization: Bearer $API_KEY" https://$OUTERHOST/grafana/api/dashboards/db --data "@/tmp/new-panel"

## Create link for embedding
# Panel
<iframe src="https://$OUTERHOST/grafana/d-solo/$DB_UID/$DB_TITLE?orgId=1&var-containergroup=All&var-interval=$__auto_interval_interval&var-server=&panelId=$PANEL_ID" width="450" height="200" frameborder="0"></iframe>
<iframe src="https://$OUTERHOST/grafana/d-solo/$DB_UID/$DB_TITLE?orgId=1&var-containergroup=All&var-interval=$__auto_interval_interval&var-server=&panelId=$PANEL_ID" width="450" height="200" frameborder="0"></iframe>

# Whole dashboard
<iframe src="https://$OUTERHOST/grafana/d/$DB_UID/$DB_TITLE?orgId=1&from=1598559391498&to=1598645791498&var-containergroup=All&var-interval=$__auto_interval_interval&var-server=" height="1200" frameborder="0"></iframe>


