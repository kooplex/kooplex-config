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
            name: 'account',
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
                secretName: 'tls-kooplex',
              },
            ],
            rules: [
              {
                host: Config.fqdn,
                http: {
                  paths: [
                    {
                      path: '/accounts',
                      pathType: 'Prefix',
                      backend: {
                        service: {
                          name: 'hub',
                          port: {
                            number: 8080,
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
        {
          apiVersion: 'networking.k8s.io/v1',
          kind: 'Ingress',
          metadata: {
            name: 'admin',
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
                secretName: 'tls-kooplex',
              },
            ],
            rules: [
              {
                host: Config.fqdn,
                http: {
                  paths: [
                    {
                      path: '/admin',
                      pathType: 'Prefix',
                      backend: {
                        service: {
                          name: 'hub',
                          port: {
                            number: 8080,
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
        {
          apiVersion: 'networking.k8s.io/v1',
          kind: 'Ingress',
          metadata: {
            name: 'root',
            namespace: Config.ns,
            annotations: {
#              'spec.ingressClassName': 'nginx',
    	      'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
   	      'traefik.ingress.kubernetes.io/router.middlewares': 'kube-system-redirect-to-https@kubernetescrd',
              'nginx.ingress.kubernetes.io/rewrite-target': '/hub',
            },
          },
          spec: {
            tls: [
              {
                hosts: [
                  Config.fqdn,
                ],
                secretName: 'tls-kooplex',
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
                          name: 'hub',
                          port: {
                            number: 8080,
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
        {
          apiVersion: 'networking.k8s.io/v1',
          kind: 'Ingress',
          metadata: {
            name: 'service',
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
                secretName: 'tls-kooplex',
              },
            ],
            rules: [
              {
                host: Config.fqdn,
                http: {
                  paths: [
                    {
                      path: '/hub',
                      pathType: 'Prefix',
                      backend: {
                        service: {
                          name: 'hub',
                          port: {
                            number: 8080,
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
        {
          apiVersion: 'networking.k8s.io/v1',
          kind: 'Ingress',
          metadata: {
            name: 'static',
            namespace: Config.ns,
            annotations: {
              'nginx.ingress.kubernetes.io/rewrite-target': '/$1',
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
                secretName: 'tls-kooplex',
              },
            ],
            rules: [
              {
                host: Config.fqdn,
                http: {
                  paths: [
                    {
                      path: '/static/(.*)',
                      pathType: 'Prefix',
                      backend: {
                        service: {
                          name: 'hub',
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
