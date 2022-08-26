local Config = import '../config.libsonnet';

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
            name: Config.hub.appname,
            namespace: Config.ns,
          },
          spec: {
            serviceName: Config.hub.appname,
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: Config.hub.appname,
              },
            },
            template: {
              metadata: {
                labels: {
                  app: Config.hub.appname,
                },
              },
              spec: {
                initContainers: [
                  {
                    name: 'init-gitclone',
                    image: 'ajeetraina/alpine-git',
                    command: [
                      'sh',
                      '-c',
                      'git clone -b kubernetes https://github.com/kooplex/kooplex-hub.git /x || true',
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/x',
                        name: 'svc',
                        subPath: 'code',
                      },
                    ],
                  },
                ],
                containers: [
                  {
                    image: 'bitnami/redis:latest',
                    name: 'redis',
                    ports: [
                      {
                        containerPort: 6379,
                        name: 'redis',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/kooplexhub',
                        name: 'svc',
                        subPath: 'redis',
                      },
                    ],
                    env: [
                      {
                        name: 'REDIS_PASSWORD',
                        value: Config.hub.redis_pw,
                      },
                    ],
                  },
                  {
                    image: Config.hub.image,
                    lifecycle: {
                      postStart: {
                        exec: {
                          command: [
                            '/bin/sh',
                            '-c',
                            "cp /root/_ssh/authorized_keys /root/.ssh/authorized_keys; echo PS1=\\'\\\\[\\\\033\\[01\\;36m\\\\]\\\\u\\\\[\\\\033\\[00m\\\\]@\\\\[\\\\033\\[00\\;32m\\\\]\\\\h-dev\\\\[\\\\033\\[00m\\\\]: \\\\[\\\\033\\[01\\;33m\\\\]\\\\w\\\\[\\\\033\\[00m\\\\]\\\\$ \\' >> /root/.bashrc",
                          ],
                        },
                      },
                    },
                    name: Config.hub.appname,
                    ports: [
                      {
                        containerPort: 80,
                        name: 'http',
                      },
                      {
                        containerPort: 3000,
                        name: 'debug',
                      },
                      {
                        containerPort: 22,
                        name: 'ssh',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/root/.kube',
                        name: 'kubeconf',
                      },
                      {
                        mountPath: '/kooplexhub',
                        name: 'svc',
                        subPath: 'code',
                      },
                      {
                        mountPath: '/var/log/hub',
                        name: 'svc',
                        subPath: 'log',
                      },
                      {
                        mountPath: '/mnt/home',
                        name: 'home',
                      },
                      {
                        mountPath: '/mnt/garbage',
                        name: 'garbage',
                      },
                      {
                        mountPath: '/mnt/projects',
                        name: 'project',
                        subPath: 'projects',
                      },
                      {
                        mountPath: '/mnt/reports',
                        name: 'report',
                      },
                      {
                        mountPath: '/mnt/report_prepare',
                        name: 'project',
                        subPath: 'report_prepare',
                      },
                      {
                        mountPath: '/mnt/courses',
                        name: 'edu',
                      },
                      {
                        mountPath: '/etc/mnt',
                        name: 'nslcd',
                        readOnly: true,
                      },
                      {
                        mountPath: '/root/_ssh',
                        name: 'authorizedkeys',
                        readOnly: true,
                      },
                      {
                        mountPath: '/.init_scripts',
                        name: 'init',
                        readOnly: true,
                      },
                    ],
                    env: [
                      {
                        name: 'HUBDBROOT_PW',
                        value: Config.hub.dbrootpw,
                      },
                      {
                        name: 'HUBDB_HOSTNAME',
                        value: 'hub-mysql',
                      },
                      {
                        name: 'LANG',
                        value: 'en_US.UTF-8',
                      },
                      {
                        name: 'DJANGO_SECRET_KEY',
                        value: Config.hub.djangosecret,
                      },
                      {
                        name: 'PREFIX',
                        value: 'k8plex-test',
                      },
                      {
                        name: 'DOMAIN',
                        value: Config.fqdn,
                      },
                      {
                        name: 'HUBDB',
                        value: Config.hub.dbname,
                      },
                      {
                        name: 'HUBDB_USER',
                        value: Config.hub.dbuser,
                      },
                      {
                        name: 'HUBDB_PW',
                        value: Config.hub.dbpw,
                      },
                      {
                        name: 'HUBLDAP_PW',
                        value: Config.ldap.pw,
                      },
                    ],
                  },
                ],
                nodeSelector: {
                  'kubernetes.io/hostname': Config.hub.nodename,
                },
                volumes: [
                  {
                    name: 'kubeconf',
                    configMap: {
                      name: 'kubeconfig',
                      items: [
                        {
                          key: 'kubeconfig',
                          path: 'config',
                        },
                      ],
                    },
                  },
                  {
                    name: 'authorizedkeys',
                    configMap: {
                      name: 'authorizedkeys',
                      items: [
                        {
                          key: 'authorizedkeys',
                          path: 'authorized_keys',
                        },
                      ],
                      defaultMode: 384,
                    },
                  },
                  {
                    name: 'svc',
                    persistentVolumeClaim: {
                      claimName: Config.hub.appname,
                    },
                  },
                  {
                    name: 'edu',
                    persistentVolumeClaim: {
                      claimName: 'edu',
                    },
                  },
                  {
                    name: 'home',
                    persistentVolumeClaim: {
                      claimName: 'home',
                    },
                  },
                  {
                    name: 'garbage',
                    persistentVolumeClaim: {
                      claimName: 'garbage',
                    },
                  },
                  {
                    name: 'project',
                    persistentVolumeClaim: {
                      claimName: 'project',
                    },
                  },
                  {
                    name: 'report',
                    persistentVolumeClaim: {
                      claimName: 'report',
                    },
                  },
                  {
                    name: 'nslcd',
                    configMap: {
                      name: 'nslcd',
                      items: [
                        {
                          key: 'nslcd',
                          path: 'nslcd.conf',
                        },
                      ],
                    },
                  },
                  {
                    name: 'init',
                    configMap: {
                      name: 'initscripts',
                      items: [
                        {
                          key: 'nsswitch',
                          path: '01-nsswitch.sh',
                        },
                        {
                          key: 'nslcd',
                          path: '02-nslcd.sh',
                        },
                        {
                          key: 'pip',
                          path: '11-pip.sh',
                        },
                        {
                          key: 'sshstart',
                          path: '21-ssh.sh',
                        },
                        {
                          key: 'celery_worker',
                          path: '98-celery_worker',
                        },
                        {
                          key: 'celery_beat',
                          path: '97-celery_beat',
                        },
                        {
                          key: 'runserver',
                          path: '99-runserver.sh',
                        },
                      ],
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
            name: Config.hub.appname + '-mysql',
            namespace: Config.ns,
          },
          spec: {
            serviceName: Config.hub.appname + '-mysql',
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: Config.hub.appname + '-mysql',
              },
            },
            template: {
              metadata: {
                labels: {
                  app: Config.hub.appname + '-mysql',
                },
              },
              spec: {
                containers: [
                  {
                    image: 'mariadb:10.5.4',
                    name: Config.hub.appname + '-mysql',
                    ports: [
                      {
                        containerPort: 3306,
                        name: 'mysql',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/var/lib/mysql',
                        name: 'svc',
                        subPath: 'mysql',
                      },
                    ],
                    env: [
                      {
                        name: 'MYSQL_ROOT_PASSWORD',
                        value: Config.hub.dbrootpw,
                      },
                      {
                        name: 'MYSQL_USER',
                        value: Config.hub.dbuser,
                      },
                      {
                        name: 'MYSQL_PASSWORD',
                        value: Config.hub.dbpw,
                      },
                      {
                        name: 'MYSQL_DATABASE',
                        value: Config.hub.dbname,
                      },
                      {
                        name: 'MYSQL_LOG_CONSOLE',
                        value: 'true',
                      },
                    ],
                  },
                ],
                nodeSelector: {
                  'kubernetes.io/hostname': Config.hub.nodename,
                },
                volumes: [
                  {
                    name: 'svc',
                    persistentVolumeClaim: {
                      claimName: Config.hub.appname,
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
