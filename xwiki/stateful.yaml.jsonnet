local Config = import 'config.libsonnet';

{
  'statefulset.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
          apiVersion: 'apps/v1',
          kind: 'StatefulSet',
          metadata: {
            name: Config.appname,
            namespace: Config.ns,
          },
          spec: {
            serviceName: 'xwiki',
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: 'xwiki',
              },
            },
            template: {
              metadata: {
                labels: {
                  app: 'xwiki',
                },
              },
              spec: {
                containers: [
                  {
                    image: 'image-registry.vo.elte.hu/xwiki',
                    name: 'xwiki',
                    ports: [
                      {
                        containerPort: 3000,
                        name: 'http',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/wiki/data/repo/',
                        name: 'data',
                        subPath: '_repo',
                      },
                    ],
                    env: [
                      {
                        name: 'DB_TYPE',
                        value: 'postgres',
                      },
                      {
                        name: 'DB_HOST',
                        value: Config.appname + '-db',
                      },
                      {
                        name: 'DB_PORT',
                        value: '5432',
                      },
                      {
                        name: 'DB_USER',
                        value: Config.dbuser,
                      },
                      {
                        name: 'DB_PASS',
                        value: Config.dbpw,
                      },
                      {
                        name: 'DB_NAME',
                        value: Config.dbname,
                      },
                    ],
                  },
                ],
                volumes: [
                  {
                    name: 'data',
                    persistentVolumeClaim: {
                      claimName: 'data',
                    },
                  },
                ],
              },
            },
          },
        },
        {
          apiVersion: 'apps/v1',
          kind: 'StatefulSet',
          metadata: {
            name: Config.appname + '-db',
            namespace: Config.ns,
          },
          spec: {
            serviceName: 'db',
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: 'xwikidb',
              },
            },
            template: {
              metadata: {
                labels: {
                  app: 'xwikidb',
                },
              },
              spec: {
                affinity: {
                  nodeAffinity: {
                    requiredDuringSchedulingIgnoredDuringExecution: {
                      nodeSelectorTerms: [
                        {
                          matchExpressions: [
                            {
                              key: 'kubernetes.io/hostname',
                              operator: 'NotIn',
                              values: [
                                'atys',
                              ],
                            },
                          ],
                        },
                      ],
                    },
                  },
                },
                containers: [
                  {
                    image: 'postgres:11-alpine',
                    name: 'db',
                    ports: [
                      {
                        containerPort: 5432,
                        name: 'postgres',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/var/lib/postgresql/data',
                        name: 'data',
                        subPath: '_xwikidb',
                      },
                    ],
                    env: [
                      {
                        name: 'POSTGRES_DB',
                        value: Config.dbname,
                      },
                      {
                        name: 'POSTGRES_PASSWORD',
                        value: Config.dbpw,
                      },
                      {
                        name: 'POSTGRES_USER',
                        value: Config.dbuser,
                      },
                    ],
                  },
                ],
                volumes: [
                  {
                    name: 'data',
                    persistentVolumeClaim: {
                      claimName: Config.pvcname,
                    },
                  },
                ],
              },
            },
          },
        },
      ],
  },
}
