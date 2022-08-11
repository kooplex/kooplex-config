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
            ports: [
              {
                name: 'gitea',
                port: 80,
                targetPort: 3000,
              },
            ],
            selector: {
              app: 'gitea',
            },
          },
        },
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: Config.appname + '-mysql',
            namespace: Config.ns,
          },
          spec: {
            ports: [
              {
                name: 'gitea-mysql',
                port: 3306,
                targetPort: 3306,
              },
            ],
            selector: {
              app: 'gitea-mysql',
            },
          },
        },
      ],
  },
}
