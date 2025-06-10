local Config = import '../config.libsonnet';

{
  'ingress.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
          apiVersion: 'networking.k8s.io/v1',
          kind: 'Ingress',
          metadata: {
            name: Config.oauth.appname,
            namespace: Config.ns,
            annotations: {
#              'spec.ingressClassName': 'nginx',
    	      'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
   	      'traefik.ingress.kubernetes.io/router.middlewares': 'kube-system-redirect-to-https@kubernetescrd'

            },
          },
          spec: {
            tls: [
              {
                hosts: [
                  Config.fqdn,
                ],
                secretName: Config.secretName,
              },
            ],
            rules: [
              {
                host: Config.fqdn,
                http: {
                  paths: [
                    {
                      path: '/'+Config.oauth.appname,
                      pathType: 'Prefix',
                      backend: {
                        service: {
                          name: Config.oauth.appname,
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
      ],
  },
}
