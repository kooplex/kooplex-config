local Config = import '../config.libsonnet';
local image = 'jupyterhub/configurable-http-proxy:4.2.1';
local nodename = 'veo1';
{
  'statefulset.yaml-raw': {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'staticreport',
      namespace: Config.ns,
    },
    spec: {
      serviceName: 'staticreport',
      podManagementPolicy: 'Parallel',
      replicas: 1,
      selector: {
        matchLabels: {
          app: 'staticreport',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'staticreport',
          },
        },
        spec: {
          containers: [
            {
              image: 'nginx',
              name: 'staticreport',
              ports: [
                {
                  containerPort: 80,
                  name: 'http',
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/srv/reports',
                  subPath: 'static/',
                  name: 'staticreports',
                },
                {
                  mountPath: '/etc/nginx/conf.d',
                  name: 'siteconf',
                },
              ],
            },
          ],
          nodeSelector: {
            'kubernetes.io/hostname': nodename,
          },
          volumes: [
            {
              name: 'staticreports',
              persistentVolumeClaim: {
                claimName: 'report',
              },
            },
            {
              name: 'siteconf',
              configMap: {
                name: 'reports-siteconf',
                items: [
                  {
                    key: 'siteconf',
                    path: 'site.conf',
                  },
                ],
              },
            },
          ],
        },
      },
    },
  },
}
