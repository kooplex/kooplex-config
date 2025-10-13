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
                  name: 'staticreports',
                },
                {
                  mountPath: '/etc/nginx/conf.d',
                  name: 'siteconf',
                },
              ],
              livenessProbe: {
                failureThreshold: 3,
                httpGet: {
                  path: '/',
                  port: 80,
                  scheme: 'HTTP',
                },
                initialDelaySeconds: 120,
                periodSeconds: 120,
                successThreshold: 1,
                timeoutSeconds: 5,
              },
              resources: {
                limits: {
                  cpu: '1',
                  memory: '4Gi',
                },
                requests: {
                  cpu: '200m',
                  memory: '1Gi',
                },
              },
            },
          ],
          //nodeSelector: {
          //  'kubernetes.io/hostname': nodename,
          //},
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
