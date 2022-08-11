local Config = import 'config.libsonnet';

{
  'ingress.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: Config.appname,
      namespace: Config.ns,
      annotations: {
        'kubernetes.io/ingress.class': 'nginx',
      },
    },
    spec: {
      rules: [
        {
          host: Config.fqdn,
          http: {
            paths: [
              {
                path: '/',
                backend: {
                  service: {
                    name: 'gitea',
                    port: {
                      number: 80,
                    },
                  },
                },
                pathType: 'Prefix',
              },
            ],
          },
        },
      ],
      tls: [
        {
          hosts: [
            Config.fqdn,
          ],
          secretName: 'tls-' + Config.appname,
        },
      ],
    },
  },
}
