local Config = import '../config.libsonnet';

{
  'ingress.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'staticreport',
      namespace: Config.ns,
      annotations: {
        'nginx.ingress.kubernetes.io/enable-cors': 'true',
        'kubernetes.io/ingress.class': 'nginx',
        'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
        'nginx.ingress.kubernetes.io/proxy-body-size': '0M',
      },
    },
    spec: {
      tls: [
        {
          hosts: [
            Config.fqdn,
          ],
          secretName: Config.ns + '-tls',
        },
      ],
      rules: [
        {
          host: Config.fqdn,
          http: {
            paths: [
              {
                path: '/report(/|$)(.*)',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: 'staticreport',
                    port: {
                      number: 80,
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
