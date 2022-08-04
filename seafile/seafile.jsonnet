local Config = import 'config.libsonnet';

{
  'statefulset.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
          apiVersion: 'apps/v1',
          kind: 'Deployment',
          metadata: {
            name: 'seafile',
            namespace: Config.ns,
            labels: {
              app: 'seafile',
            },
          },
          spec: {
            replicas: 1,
            selector: {
              matchLabels: {
                app: 'seafile',
              },
            },
            strategy: {
              type: 'Recreate',
            },
            template: {
              metadata: {
                labels: {
                  app: 'seafile',
                },
              },
              spec: {
                hostAliases: [
                  {
                    ip: '127.0.0.1',
                    hostnames: [
                      'memcached',
                    ],
                  },
                ],
                containers: [
                  {
                    image: 'mariadb:10.5',
                    name: 'seafile-mysql',
                    env: [
                      {
                        name: 'MYSQL_ROOT_PASSWORD',
                        value: Config.dbrootpw,
                      },
                      {
                        name: 'MYSQL_LOG_CONSOLE',
                        value: 'true',
                      },
                    ],
                    volumeMounts: [
                      {
                        name: 'seafile-data',
                        mountPath: '/var/lib/mysql/',
                        subPath: 'db',
                      },
                    ],
                  },
                  {
                    image: 'memcached:1.5.6',
                    name: 'seafile-memcached',
                    command: [
                      'memcached',
                    ],
                    args: [
                      '-m 256',
                    ],
                  },
                  {
                    image: 'seafileltd/seafile-mc:9.0.5',
                    name: 'seafile',
                    command: [
                      '/bin/sh',
                      '-c',
                    ],
                    args: [
                      'pip install requests_oauthlib; /sbin/my_init -- /scripts/enterpoint.sh',
                    ],
                    env: [
                      {
                        name: 'DB_HOST',
                        value: '127.0.0.1',
                      },
                      {
                        name: 'DB_ROOT_PASSWD',
                        value: Config.dbrootpw,
                      },
                      {
                        name: 'SEAFILE_ADMIN_EMAIL',
                        value: 'kooplex@elte.hu',
                      },
                      {
                        name: 'SEAFILE_ADMIN_PASSWORD',
                        value: Config.adminpw,
                      },
                      {
                        name: 'SEAFILE_SERVER_LETSENCRYPT',
                        value: 'false',
                      },
                      {
                        name: 'SEAFILE_SERVER_HOSTNAME',
                        value: Config.fqdn,
                      },
                    ],
                    volumeMounts: [
                      {
                        name: 'seafile-data',
                        mountPath: '/shared/',
                        subPath: 'data',
                      },
                    ],
                    ports: [
                      {
                        containerPort: 80,
                      },
                    ],
                  },
                ],
                volumes: [
                  {
                    name: 'seafile-data',
                    persistentVolumeClaim: {
                      claimName: 'seafile-data',
                    },
                  },
                ],
              },
            },
          },
        },
        {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
            name: 'seafile',
            namespace: Config.ns,
          },
          spec: {
            ports: [
              {
                name: 'seahub',
                port: 80,
                targetPort: 80,
              },
            ],
            selector: {
              app: 'seafile',
            },
          },
        },
        {
          apiVersion: 'networking.k8s.io/v1',
          kind: 'Ingress',
          metadata: {
            name: 'seafile',
            namespace: Config.ns,
            annotations: {
              'kubernetes.io/ingress.class': 'nginx',
            },
          },
          spec: {
            rules: [
              {
                host: Config.fqdn,
                http: {
                  paths: [
                    {
                      path: '/',
                      backend: {
                        service: {
                          name: 'seafile',
                          port: {
                            number: 80,
                          },
                        },
                      },
                      pathType: 'Prefix',
                    },
                  ],
                },
              },
            ],
            tls: [
              {
                hosts: [
                  Config.fqdn,
                ],
                secretName: 'tls-' + Config.ns,
              },
            ],
          },
        },
      ],
  },
}
