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
        'nginx.ingress.kubernetes.io/rewrite-target': '/',
      },
    },
    spec: {
      tls: [
        {
          hosts: [
            Config.fqdn,
          ],
          secretName: 'tls-' + Config.appname,
        },
      ],
      rules: [
        {
          host: Config.fqdn,
          http: {
            paths: [
              {
                path: '/',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: 'xwiki',
                    port: {
                      number: 3000,
                    },
                  },
                },
              },
            ],
          },
        },
      ],
    },
  },
}
