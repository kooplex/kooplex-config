local Config = import 'config.libsonnet';

{
  'svc.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: Config.appname,
            namespace: Config.ns,
          },
          spec: {
            selector: {
              app: 'xwiki',
            },
            ports: [
              {
                name: 'http',
                protocol: 'TCP',
                port: 3000,
                targetPort: 3000,
              },
            ],
          },
        },
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: Config.appname + '-db',
            namespace: Config.ns,
          },
          spec: {
            selector: {
              app: 'xwikidb',
            },
            ports: [
              {
                name: 'postgres',
                protocol: 'TCP',
                port: 5432,
                targetPort: 5432,
              },
            ],
          },
        },
      ],
  },
}
