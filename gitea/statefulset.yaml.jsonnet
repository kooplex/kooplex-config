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
            serviceName: 'gitea',
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: 'gitea',
              },
            },
            template: {
              metadata: {
                labels: {
                  app: 'gitea',
                },
              },
              spec: {
                containers: [
                  {
                    name: 'gitea',
                    image: 'gitea/gitea:1.18.3',
                    env: [
                      {
                        name: 'GITEA__database__DB_TYPE',
                        value: 'mysql',
                      },
                      {
                        name: 'GITEA__database__HOST',
                        value: 'gitea-mysql:3306',
                      },
                      {
                        name: 'GITEA__database__NAME',
                        value: Config.dbname,
                      },
                      {
                        name: 'GITEA__database__USER',
                        value: Config.dbuser,
                      },
                      {
                        name: 'GITEA__database__PASSWD',
                        value: Config.dbpw,
                      },
                    ],
                    ports: [
                      {
                        containerPort: 3000,
                        name: 'gitea',
                      },
                      {
                        containerPort: 30576,
                        name: 'git-ssh',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/data',
                        name: 'git-volume',
                        subPath: 'data',
                      },
                    ],
                    resources: {
                      requests: {
                        cpu: '1',
                        memory: '400Mi',
                      },
                      limits: {
                        cpu: '2',
                        memory: '4Gi',
                      },
                    },
                  },
                ],
                volumes: [
                  {
                    name: 'git-volume',
                    persistentVolumeClaim: {
                      claimName: Config.pvcname,
                    },
                  },
                ],
                nodeSelector: {
                  'kubernetes.io/hostname': Config.nodename,
                },
              },
            },
          },
        },
        {
          apiVersion: 'apps/v1',
          kind: 'StatefulSet',
          metadata: {
            name: Config.appname + '-mysql',
            namespace: Config.ns,
          },
          spec: {
            serviceName: 'gitea-mysql',
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: 'gitea-mysql',
              },
            },
            template: {
              metadata: {
                labels: {
                  app: 'gitea-mysql',
                },
              },
              spec: {
                containers: [
                  {
                    image: 'mariadb:10.5',
                    name: 'gitea-mysql',
                    env: [
                      {
                        name: 'MYSQL_ROOT_PASSWORD',
                        value: Config.dbrootpw,
                      },
                      {
                        name: 'MYSQL_LOG_CONSOLE',
                        value: 'true',
                      },
                      {
                        name: 'MYSQL_USER',
                        value: Config.dbuser,
                      },
                      {
                        name: 'MYSQL_PASSWORD',
                        value: Config.dbpw,
                      },
                      {
                        name: 'MYSQL_DATABASE',
                        value: Config.dbname,
                      },
                    ],
                    volumeMounts: [
                      {
                        name: 'git-volume',
                        mountPath: '/var/lib/mysql/',
                        subPath: 'db',
                      },
                    ],
                  },
                ],
                nodeSelector: {
                  'kubernetes.io/hostname': Config.nodename,
                },
                volumes: [
                  {
                    name: 'git-volume',
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
