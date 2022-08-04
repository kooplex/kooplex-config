local Config = import '../config.libsonnet';

{
  'svc_provider.yaml-raw': {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: Config.ldap.appname,
      namespace: Config.ns,
    },
    spec: {
      selector: {
        app: Config.ldap.appname,
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
