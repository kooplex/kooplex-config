local Config = import '../config.libsonnet';

{
  'svc_shiny.yaml-raw': {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'shinyreport',
      namespace: Config.ns,
    },
    spec: {
      selector: {
        app: 'shinyreport',
      },
      ports: [
        {
          name: 'http',
          protocol: 'TCP',
          port: 3838,
          targetPort: 3838,
        },
      ],
    },
  },
}
