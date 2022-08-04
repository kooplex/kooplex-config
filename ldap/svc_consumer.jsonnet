local Config = import '../config.libsonnet';

{
  'svc_consumer.yaml-raw': {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: Config.ldap.appname + '2',
      namespace: Config.ns,
    },
    spec: {
      selector: {
        app: Config.ldap.appname + '-consumer',
      },
      ports: [
        {
          name: 'ldap',
          port: 389,
          targetPort: 389,
        },
      ],
    },
  },
}
