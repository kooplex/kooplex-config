local Config = import '../config.libsonnet';

{
  'svc.yaml-raw': {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'staticreport',
      namespace: Config.ns,
    },
    spec: {
      selector: {
        app: 'staticreport',
      },
      ports: [
        {
          name: 'http',
          protocol: 'TCP',
          port: 80,
          targetPort: 80,
        },
      ],
    },
  },
}
