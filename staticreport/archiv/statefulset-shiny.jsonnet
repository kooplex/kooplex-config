local Config = import '../config.libsonnet';
local image = 'image-registry.vo.elte.hu/report-shiny-v5';
local nodename = 'future1';
{
  'statefulset_shiny.yaml-raw': {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'shinyreport',
      namespace: Config.ns,
    },
    spec: {
      serviceName: 'shinyreport',
      podManagementPolicy: 'Parallel',
      replicas: 1,
      selector: {
        matchLabels: {
          app: 'shinyreport',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'shinyreport',
          },
        },
        spec: {
          containers: [
            {
              image: image,
              name: 'shinyreport',
              ports: [
                {
                  containerPort: 3838,
                  name: 'http',
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/srv/report',
                  name: 'staticreports',
                },
                //                {
                //                  mountPath: '/etc/nginx/conf.d',
                //                  name: 'siteconf',
                //                },
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
            //            {
            //              name: 'siteconf',
            //              configMap: {
            //                name: 'reports-siteconf',
            //                items: [
            //                  {
            //                    key: 'siteconf',
            //                    path: 'site.conf',
            //                  },
            //                ],
            //              },
            //           },
          ],
        },
      },
    },
  },
}
