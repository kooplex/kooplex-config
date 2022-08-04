filen="node-overview.json"

cat << EOF > $filen
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "target": {
          "limit": 100,
          "matchAny": false,
          "tags": [],
          "type": "dashboard"
        },
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 1,
  "id": 29,
  "iteration": 1652192287405,
  "links": [],
  "panels": [

EOF
Y=0
D=20

for node in veo1 veo2 onco1 kubelet1-onco2 kubelet2-onco2 future1 atys kubelet1-fiek-cn3 kubelet2-fiek-cn3 kubelet3-fiek-cn3 kubelet6-fiek-cn3 kubelet7-fiek-cn3 kubelet1-fiek-cn4 kubelet3-fiek-cn4 kubelet4-fiek-cn4
	do
		echo $Y,$D,$node
		cat temp.json |sed -e "s,\"y\": 0,\"y\": $Y," |sed -e "s,\"id\": 1,\"id\": $D," |sed -e "s,onco1,$node,g" | sed -e "s, ##NODE##, $node," >> $filen
		Y=$((Y+7))
		D=$((D+1))
	done


cat << EOF >> $filen
],
  "refresh": "30s",
  "schemaVersion": 30,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": [
      {
        "current": {
          "selected": false,
          "text": "prometheus",
          "value": "prometheus"
        },
        "description": null,
        "error": null,
        "hide": 0,
        "includeAll": false,
        "label": null,
        "multi": false,
        "name": "datasource",
        "options": [],
        "query": "prometheus",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "type": "datasource"
      }
    ]
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "utc",
  "title": "Node overview",
  "uid": "dCaIoc_nk"
}
EOF

