local Config = import '../config.libsonnet';

{
 'svc.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
       {
         "apiVersion": "v1",
         "kind": "Service",
         "metadata": {
           "name": Config.oauth.appname,
           "namespace": Config.ns
         },
         "spec": {
           "selector": {
             "app": Config.oauth.appname
           },
           "ports": [
             {
               "name": "http",
               "protocol": "TCP",
               "port": 80,
               "targetPort": 80
             }
           ]
         }
       },
       {
         "apiVersion": "v1",
         "kind": "Service",
         "metadata": {
           "name": Config.oauth.dbhostname,
           "namespace": Config.ns
         },
         "spec": {
           "selector": {
             "app": Config.oauth.dbhostname
           },
           "ports": [
             {
               "name": "mysql",
               "protocol": "TCP",
               "port": 3306,
               "targetPort": 3306
             }
           ]
         }
       }
      ],
  },
}

