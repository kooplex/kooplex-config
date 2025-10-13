local Config = import '../config.libsonnet';

{
  'service.yaml-raw': {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: Config.proxy.appname,
      namespace: Config.ns,
    },
    spec: {
      selector: {
        app: Config.proxy.appname,
      },
      ports: [
        {
          name: 'http',
          protocol: 'TCP',
          port: 8000,
          targetPort: 8000,
        },
        {
          name: 'api',
          protocol: 'TCP',
          port: 8001,
          targetPort: 8001,
        },
      ],
    },
  },
  'statefulset.yaml-raw': {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: Config.proxy.appname,
      namespace: Config.ns,
    },
    spec: {
      serviceName: Config.proxy.appname,
      podManagementPolicy: 'Parallel',
      replicas: 1,
      selector: {
        matchLabels: {
          app: $['service.yaml-raw'].spec.selector.app,
        },
      },
      template: {
        metadata: {
          labels: {
            app: Config.proxy.appname,
          },
        },
        spec: {
          containers: [
            {
              image: Config.proxy.image,
              name: Config.proxy.appname,
              command: [
                'node',
                '/usr/local/bin/configurable-http-proxy',
                '--api-ip=0.0.0.0',
                '--error-path=/var/html',
              ],
                    resources: {
                      requests: {
                        cpu: '100m',
                        memory: '40Mi',
                      },
                      limits: {
                        cpu: '200m',
                        memory: '100Mi',
                      },
                    },
              ports: [
                {
                  containerPort: 8000,
                  name: 'http',
                },
                {
                  containerPort: 8001,
                  name: 'api',
                },
              ],
              resources: {
                requests: {
                  cpu: '300m',
                  memory: '200Mi',
                },
              },
              volumeMounts: [
                {
                  mountPath: '/var/html',
                  name: 'errorhtml',
                },
              ],
            },
          ],
          //nodeSelector: {
          //  'kubernetes.io/hostname': nodename,
          //},
          volumes: [
            {
              name: 'errorhtml',
              configMap: {
                name: 'errorhtml',
                items: [
                  {
                    key: 'error',
                    path: 'error.html',
                  },
                ],
              },
            },
          ],
        },
      },
    },
  },

  'ingress_notebook.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: Config.proxy.appname + '-notebook',
      namespace: Config.ns,
      annotations: {
#        'kubernetes.io/ingress.class': 'nginx',
        'nginx.ingress.kubernetes.io/proxy-body-size': '0',
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
                path: '/notebook',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: 'proxy',
                    port: {
                      number: 8000,
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
  'configmap_errorhtml.yaml-raw': {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'errorhtml',
      namespace: Config.ns,
    },
    data: {
      'error': '<META HTTP-EQUIV="refresh" CONTENT="5">\n<h3>Note: notebook server not yet ready</h3>\n<p><strong>Please wait a bit, this page reloads every 5 seconds!</strong></p>\n<p><span>Description:</span> the resources have been allocated for your environment, but the notebook server had not enough time to initialize. Usually this takes only a couple of seconds on an empty server and 1-2 minutes if it is heavily loaded.</p>  \n',
    },
  },
}
