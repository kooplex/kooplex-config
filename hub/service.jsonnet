local Config = import '../config.libsonnet';

{
  'service_hub.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: 'hub',
            namespace: Config.ns,
          },
          spec: {
            selector: {
              app: 'hub',
            },
            ports: [
              {
                name: 'http',
                protocol: 'TCP',
                port: 8080,
                targetPort: 8080,
              },
              {
                name: 'httpstatic',
                protocol: 'TCP',
                port: 80,
                targetPort: 80,
              },
            ],
          },
        },
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: 'hub-mysql',
            namespace: Config.ns,
          },
          spec: {
            selector: {
              app: 'hub-mysql',
            },
            ports: [
              {
                name: 'mysql',
                protocol: 'TCP',
                port: 3306,
                targetPort: 3306,
              },
            ],
          },
        },
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: 'hub-debug',
            namespace: Config.ns,
          },
          spec: {
            selector: {
              app: 'hub',
            },
            ports: [
              {
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
            name: 'hub-ssh',
            namespace: Config.ns,
          },
          spec: {
            selector: {
              app: 'hub',
            },
            ports: [
              {
                protocol: 'TCP',
                port: 222,
                targetPort: 22,
              },
            ],
          },

        },
      ],
  },
}
