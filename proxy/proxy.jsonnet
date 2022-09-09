local Config = import '../config.libsonnet';
local appname = 'proxy';
local image = 'jupyterhub/configurable-http-proxy:4.2.1';
local nodename = 'veo1';

{
  'service.yaml-raw': {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: appname,
      namespace: Config.ns,
    },
    spec: {
      selector: {
        app: appname,
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
      name: appname,
      namespace: Config.ns,
    },
    spec: {
      serviceName: appname,
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
            app: appname,
          },
        },
        spec: {
          containers: [
            {
              image: image,
              name: appname,
              command: [
                'node',
                '/usr/local/bin/configurable-http-proxy',
                '--api-ip=0.0.0.0',
                '--error-path=/var/html',
              ],
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
              volumeMounts: [
                {
                  mountPath: '/var/html',
                  name: 'errorhtml',
                },
              ],
            },
          ],
          nodeSelector: {
            'kubernetes.io/hostname': nodename,
          },
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
      name: appname,
      namespace: Config.ns,
      annotations: {
        'kubernetes.io/ingress.class': 'nginx',
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
  'ingress_dynamic_report.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: appname + '-dynamic-report',
      namespace: Config.ns,
      annotations: {
        'kubernetes.io/ingress.class': 'nginx',
        'nginx.org/websocket-services': appname,
        'nginx.ingress.kubernetes.io/proxy-body-size': '0',
        'nginx.ingress.kubernetes.io/proxy-buffer-size': '16k',
        'nginx.ingress.kubernetes.io/client-header-buffers': '100k',
        'nginx.ingress.kubernetes.io/large-client-header-buffers': '4 1000k',
        'nginx.ingress.kubernetes.io/client-body-buffer-size': '10M',
        'nginx.ingress.kubernetes.io/proxy-add-original-uri-header': 'false',
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
                path: '/dreport',
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
